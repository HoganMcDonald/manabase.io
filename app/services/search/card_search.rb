# frozen_string_literal: true

module Search
  class CardSearch < Base
    def autocomplete(query, limit: 10)
      return [] if query.blank?

      search_body = {
        query: {
          bool: {
            should: [
              {
                match: {
                  "name.autocomplete": {
                    query: query,
                    boost: 2
                  }
                }
              },
              {
                match_phrase_prefix: {
                  name: {
                    query: query,
                    boost: 3
                  }
                }
              }
            ]
          }
        },
        _source: ["name", "type_line", "mana_cost"],
        size: limit
      }

      response = client.search(
        index: index_name,
        body: search_body
      )

      format_autocomplete_results(response)
    rescue StandardError => e
      Rails.logger.error("OpenSearch autocomplete failed: #{e.message}")
      []
    end

    def search(query, filters: {}, page: 1, per_page: 20, search_mode: "auto")
      # Determine which search mode to use
      mode = determine_search_mode(query, search_mode)

      search_body = case mode
      when "semantic"
        build_semantic_search_query(query, filters)
      when "hybrid"
        build_hybrid_search_query(query, filters)
      else
        build_search_query(query, filters)
      end

      search_body[:from] = (page - 1) * per_page
      search_body[:size] = per_page

      response = client.search(
        index: index_name,
        body: search_body
      )

      format_search_results(response, page, per_page)
    rescue StandardError => e
      Rails.logger.error("OpenSearch search failed: #{e.message}")
      {
        results: [],
        total: 0,
        page: page,
        per_page: per_page,
        total_pages: 0
      }
    end

    private

    def build_search_query(query, filters)
      query_clauses = []
      filter_clauses = []

      # Text search across multiple fields
      if query.present?
        query_clauses << {
          multi_match: {
            query: query,
            fields: ["name^3", "oracle_text", "type_line^2", "card_faces.name^2", "card_faces.oracle_text"],
            type: "best_fields",
            fuzziness: "AUTO"
          }
        }
      end

      # Color identity filter
      if filters[:colors].present?
        colors = Array(filters[:colors])
        if filters[:color_match] == "exact"
          filter_clauses << {terms: {color_identity: colors}}
        else
          # Default: cards that include all specified colors
          colors.each do |color|
            filter_clauses << {term: {color_identity: color}}
          end
        end
      end

      # CMC (mana value) filters
      if filters[:cmc_min].present? || filters[:cmc_max].present?
        cmc_filter = {range: {cmc: {}}}
        cmc_filter[:range][:cmc][:gte] = filters[:cmc_min].to_f if filters[:cmc_min].present?
        cmc_filter[:range][:cmc][:lte] = filters[:cmc_max].to_f if filters[:cmc_max].present?
        filter_clauses << cmc_filter
      end

      # Type line filter (partial match)
      if filters[:types].present?
        Array(filters[:types]).each do |card_type|
          filter_clauses << {
            match: {
              type_line: {
                query: card_type,
                operator: "and"
              }
            }
          }
        end
      end

      # Format legality filter
      if filters[:formats].present?
        Array(filters[:formats]).each do |format|
          filter_clauses << {
            term: {
              "legalities.#{format}": "legal"
            }
          }
        end
      end

      # Keyword filter
      if filters[:keywords].present?
        Array(filters[:keywords]).each do |keyword|
          filter_clauses << {term: {keywords: keyword}}
        end
      end

      # Layout filter
      if filters[:layout].present?
        filter_clauses << {term: {layout: filters[:layout]}}
      end

      # Reserved list filter
      if filters[:reserved].present?
        filter_clauses << {term: {reserved: filters[:reserved] == "true"}}
      end

      # Rarity filter
      if filters[:rarities].present?
        filter_clauses << {terms: {rarity: Array(filters[:rarities])}}
      end

      # Power filter
      if filters[:power_min].present? || filters[:power_max].present?
        power_filter = {range: {power: {}}}
        power_filter[:range][:power][:gte] = filters[:power_min].to_i if filters[:power_min].present?
        power_filter[:range][:power][:lte] = filters[:power_max].to_i if filters[:power_max].present?
        filter_clauses << power_filter
      end

      # Toughness filter
      if filters[:toughness_min].present? || filters[:toughness_max].present?
        toughness_filter = {range: {toughness: {}}}
        toughness_filter[:range][:toughness][:gte] = filters[:toughness_min].to_i if filters[:toughness_min].present?
        toughness_filter[:range][:toughness][:lte] = filters[:toughness_max].to_i if filters[:toughness_max].present?
        filter_clauses << toughness_filter
      end

      # Build the final query
      {
        query: {
          bool: {
            must: query_clauses.any? ? query_clauses : [{match_all: {}}],
            filter: filter_clauses
          }
        },
        sort: build_sort_options(filters[:sort]),
        _source: true
      }
    end

    def build_sort_options(sort_param)
      case sort_param
      when "name"
        [{"name.keyword": {order: "asc"}}]
      when "cmc"
        [{cmc: {order: "asc"}}, {"name.keyword": {order: "asc"}}]
      when "released"
        [{released_at: {order: "desc"}}]
      else
        ["_score", {"name.keyword": {order: "asc"}}]
      end
    end

    def format_autocomplete_results(response)
      hits = response.dig("hits", "hits") || []
      hits.map do |hit|
        source = hit["_source"]
        {
          id: hit["_id"],
          name: source["name"],
          type_line: source["type_line"],
          mana_cost: source["mana_cost"]
        }
      end
    end

    def format_search_results(response, page, per_page)
      hits = response.dig("hits", "hits") || []
      total = response.dig("hits", "total", "value") || 0

      results = hits.map do |hit|
        card_data = hit["_source"]
        # Remove embedding from results to reduce payload size
        card_data.delete("embedding")
        card_data.merge(
          id: hit["_id"],
          score: hit["_score"]
        )
      end

      {
        results: results,
        total: total,
        page: page,
        per_page: per_page,
        total_pages: (total.to_f / per_page).ceil
      }
    end

    # Determine which search mode to use based on query and mode parameter
    def determine_search_mode(query, search_mode)
      return search_mode unless search_mode == "auto"
      return "keyword" if query.blank?

      query_lower = query.downcase
      word_count = query.split.length

      # Exact card name patterns - use keyword for precision
      # Match patterns like "Lightning Bolt", "Black Lotus"
      # Capitalized words or quoted strings suggest exact names
      if query.match?(/^["'].*["']$/) || (word_count <= 4 && query.match?(/^[A-Z]/))
        return "keyword"
      end

      # Effect-based queries - use hybrid for semantic + keyword
      effect_phrases = [
        "cards that", "cards with", "spells that", "creatures that",
        "draw cards", "remove", "destroy", "exile", "counter",
        "sacrifice", "discard", "mill", "tutor", "ramp",
        "life gain", "lifelink", "flying", "trample", "haste",
        "triggers", "when", "whenever", "enters the battlefield",
        "dies", "attacks", "blocks"
      ]
      contains_effect = effect_phrases.any? { |phrase| query_lower.include?(phrase) }

      # Question words indicate natural language queries
      question_words = ["what", "how", "which", "who", "find me", "show me", "looking for"]
      contains_question = question_words.any? { |word| query_lower.include?(word) }

      # MTG slang/nicknames - use hybrid for semantic understanding
      slang_terms = ["dork", "wrath", "counterspell", "removal", "board wipe", "ramp", "tutor"]
      contains_slang = slang_terms.any? { |term| query_lower.include?(term) }

      # Descriptive queries (adjectives + nouns) suggest semantic
      descriptive_patterns = [
        "cheap", "expensive", "powerful", "best", "good", "bad",
        "fast", "slow", "efficient", "inefficient"
      ]
      contains_descriptive = descriptive_patterns.any? { |word| query_lower.include?(word) }

      # Decision logic
      if contains_effect || contains_question || contains_slang || contains_descriptive
        "hybrid" # Natural language or effect-based queries benefit from both
      elsif word_count > 5
        "hybrid" # Longer queries likely descriptive
      elsif word_count >= 2
        "keyword" # Short multi-word queries likely card names or types
      else
        "keyword" # Single word searches (card names, types)
      end
    end

    # Build a pure semantic search query using k-NN
    def build_semantic_search_query(query, filters)
      query_embedding = EmbeddingService.embed(query)

      # Fall back to keyword search if embedding fails
      return build_search_query(query, filters) if query_embedding.blank?

      filter_clauses = build_filter_clauses(filters)

      # Use k-NN with post-filtering for better semantic ranking
      # Get more candidates (k=200) and then filter to allow semantic relevance to dominate
      search_query = {
        size: 20, # Will be overridden by caller
        query: {
          knn: {
            embedding: {
              vector: query_embedding,
              k: 200 # Increased k to get more candidates before filtering
            }
          }
        },
        _source: {excludes: ["embedding"]}
      }

      # Apply filters as post-filter if any exist
      # This preserves semantic ranking while still filtering results
      if filter_clauses.any?
        search_query[:post_filter] = {
          bool: {
            filter: filter_clauses
          }
        }
      end

      search_query
    end

    # Build a hybrid search query combining k-NN and keyword search
    def build_hybrid_search_query(query, filters)
      query_embedding = EmbeddingService.embed(query)

      # Fall back to keyword search if embedding fails
      return build_search_query(query, filters) if query_embedding.blank?

      filter_clauses = build_filter_clauses(filters)

      # Hybrid approach: Use script_score to combine k-NN similarity with keyword relevance
      # This properly combines both signals into a single score
      {
        query: {
          script_score: {
            query: {
              bool: {
                should: [
                  # Keyword search component
                  {
                    multi_match: {
                      query: query,
                      fields: ["name^3", "oracle_text", "type_line^2", "card_faces.name^2", "card_faces.oracle_text"],
                      type: "best_fields",
                      fuzziness: "AUTO"
                    }
                  }
                ],
                filter: filter_clauses,
                minimum_should_match: 0 # Allow either keyword or semantic to match
              }
            },
            script: {
              source: """
                double keywordScore = Math.max(_score, 0.1);
                double vectorScore = cosineSimilarity(params.query_vector, 'embedding') + 1.0;
                return (vectorScore * 3.0) + (keywordScore * 1.0);
              """,
              params: {
                query_vector: query_embedding
              }
            }
          }
        },
        _source: {excludes: ["embedding"]}
      }
    end

    # Extract filter building logic for reuse
    def build_filter_clauses(filters)
      filter_clauses = []

      # Color identity filter
      if filters[:colors].present?
        colors = Array(filters[:colors])
        if filters[:color_match] == "exact"
          filter_clauses << {terms: {color_identity: colors}}
        else
          colors.each do |color|
            filter_clauses << {term: {color_identity: color}}
          end
        end
      end

      # CMC filters
      if filters[:cmc_min].present? || filters[:cmc_max].present?
        cmc_filter = {range: {cmc: {}}}
        cmc_filter[:range][:cmc][:gte] = filters[:cmc_min].to_f if filters[:cmc_min].present?
        cmc_filter[:range][:cmc][:lte] = filters[:cmc_max].to_f if filters[:cmc_max].present?
        filter_clauses << cmc_filter
      end

      # Type line filter
      if filters[:types].present?
        Array(filters[:types]).each do |card_type|
          filter_clauses << {
            match: {
              type_line: {
                query: card_type,
                operator: "and"
              }
            }
          }
        end
      end

      # Format legality filter
      if filters[:formats].present?
        Array(filters[:formats]).each do |format|
          filter_clauses << {
            term: {
              "legalities.#{format}": "legal"
            }
          }
        end
      end

      # Keyword filter
      if filters[:keywords].present?
        Array(filters[:keywords]).each do |keyword|
          filter_clauses << {term: {keywords: keyword}}
        end
      end

      # Layout filter
      if filters[:layout].present?
        filter_clauses << {term: {layout: filters[:layout]}}
      end

      # Reserved list filter
      if filters[:reserved].present?
        filter_clauses << {term: {reserved: filters[:reserved] == "true"}}
      end

      # Rarity filter
      if filters[:rarities].present?
        filter_clauses << {terms: {rarity: Array(filters[:rarities])}}
      end

      # Power filter
      if filters[:power_min].present? || filters[:power_max].present?
        power_filter = {range: {power: {}}}
        power_filter[:range][:power][:gte] = filters[:power_min].to_i if filters[:power_min].present?
        power_filter[:range][:power][:lte] = filters[:power_max].to_i if filters[:power_max].present?
        filter_clauses << power_filter
      end

      # Toughness filter
      if filters[:toughness_min].present? || filters[:toughness_max].present?
        toughness_filter = {range: {toughness: {}}}
        toughness_filter[:range][:toughness][:gte] = filters[:toughness_min].to_i if filters[:toughness_min].present?
        toughness_filter[:range][:toughness][:lte] = filters[:toughness_max].to_i if filters[:toughness_max].present?
        filter_clauses << toughness_filter
      end

      filter_clauses
    end
  end
end
