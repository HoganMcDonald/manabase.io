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

    def search(query, filters: {}, page: 1, per_page: 20)
      search_body = build_search_query(query, filters)
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
  end
end
