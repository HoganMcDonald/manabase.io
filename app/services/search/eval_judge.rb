# frozen_string_literal: true

module Search
  # LLM-as-judge for evaluating search result relevance
  # Uses OpenAI via ruby_llm to rate how relevant search results are to queries
  class EvalJudge
    JUDGE_MODEL = "gpt-4o-mini"

    class << self
      # Evaluate the relevance of search results for a query
      # @param query [String] The search query
      # @param results [Array<Hash>] The search results with card data
      # @param expected_cards [Array<String>] Expected card names (for context)
      # @return [Hash] Evaluation with scores and reasoning
      def evaluate_results(query, results, expected_cards: [])
        return {error: "No results to evaluate"} if results.empty?

        ensure_configured!

        # Take top 10 results for evaluation
        top_results = results.first(10)

        prompt = build_evaluation_prompt(query, top_results, expected_cards)

        begin
          response = RubyLLM.chat(prompt, model: JUDGE_MODEL, temperature: 0.0)
          parse_evaluation_response(response)
        rescue StandardError => e
          Rails.logger.error("LLM evaluation failed: #{e.message}")
          Rails.logger.error(e.backtrace.first(5).join("\n"))
          {error: e.message}
        end
      end

      # Evaluate a single result's relevance to a query
      # @param query [String] The search query
      # @param result [Hash] A single search result
      # @return [Hash] Score (1-5) and reasoning
      def evaluate_single_result(query, result)
        ensure_configured!

        prompt = build_single_evaluation_prompt(query, result)

        begin
          response = RubyLLM.chat(prompt, model: JUDGE_MODEL, temperature: 0.0)
          parse_single_evaluation(response)
        rescue StandardError => e
          Rails.logger.error("LLM single evaluation failed: #{e.message}")
          {score: 0, reasoning: "Evaluation failed: #{e.message}"}
        end
      end

      private

      def ensure_configured!
        return if @configured

        RubyLLM.configure do |config|
          config.openai_api_key = ENV.fetch("OPENAI_API_KEY")
        end
        @configured = true
      rescue KeyError => e
        Rails.logger.error("OPENAI_API_KEY environment variable not set")
        raise
      end

      def build_evaluation_prompt(query, results, expected_cards)
        results_text = results.map.with_index do |result, idx|
          card_text = format_card_for_prompt(result)
          "#{idx + 1}. #{card_text}"
        end.join("\n\n")

        expected_text = if expected_cards.any?
          "\n\nExpected relevant cards include: #{expected_cards.join(", ")}"
        else
          ""
        end

        <<~PROMPT
          You are evaluating Magic: The Gathering card search results for relevance.

          Query: "#{query}"#{expected_text}

          Please rate each of the following search results for relevance to the query on a scale of 1-5:
          - 5: Highly relevant, perfect match for the query
          - 4: Very relevant, good match
          - 3: Somewhat relevant, partial match
          - 2: Barely relevant, weak connection
          - 1: Not relevant, unrelated to query

          Results:
          #{results_text}

          Respond with JSON in this exact format:
          {
            "results": [
              {"rank": 1, "name": "Card Name", "score": 5, "reasoning": "Why this score"},
              {"rank": 2, "name": "Card Name", "score": 4, "reasoning": "Why this score"}
            ],
            "overall_quality": "Brief assessment of overall search quality"
          }
        PROMPT
      end

      def build_single_evaluation_prompt(query, result)
        card_text = format_card_for_prompt(result)

        <<~PROMPT
          You are evaluating a Magic: The Gathering card search result for relevance.

          Query: "#{query}"

          Card:
          #{card_text}

          Rate this card's relevance to the query on a scale of 1-5:
          - 5: Highly relevant, perfect match
          - 4: Very relevant, good match
          - 3: Somewhat relevant, partial match
          - 2: Barely relevant, weak connection
          - 1: Not relevant, unrelated

          Respond with JSON in this exact format:
          {
            "score": 4,
            "reasoning": "Brief explanation of why this score"
          }
        PROMPT
      end

      def format_card_for_prompt(result)
        name = result[:name] || result["name"]
        type_line = result[:type_line] || result["type_line"]
        oracle_text = result[:oracle_text] || result["oracle_text"]
        mana_cost = result[:mana_cost] || result["mana_cost"]

        parts = []
        parts << "Name: #{name}" if name
        parts << "Type: #{type_line}" if type_line
        parts << "Mana Cost: #{mana_cost}" if mana_cost.present?
        parts << "Text: #{oracle_text}" if oracle_text.present?

        parts.join("\n")
      end

      def parse_evaluation_response(response)
        # RubyLLM returns a hash-like object, extract the content
        content = if response.respond_to?(:content)
          response.content
        elsif response.is_a?(Hash)
          response["content"] || response[:content]
        else
          response.to_s
        end

        # Try to extract JSON from the response
        json_match = content.match(/\{.*\}/m)
        return {error: "No JSON found in response"} unless json_match

        parsed = JSON.parse(json_match[0])

        {
          results: parsed["results"] || [],
          overall_quality: parsed["overall_quality"],
          average_score: calculate_average_score(parsed["results"])
        }
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse LLM response: #{e.message}")
        {error: "Failed to parse response", raw_response: content}
      end

      def parse_single_evaluation(response)
        content = if response.respond_to?(:content)
          response.content
        elsif response.is_a?(Hash)
          response["content"] || response[:content]
        else
          response.to_s
        end

        json_match = content.match(/\{.*\}/m)
        return {score: 0, reasoning: "No JSON in response"} unless json_match

        parsed = JSON.parse(json_match[0])
        {
          score: parsed["score"] || 0,
          reasoning: parsed["reasoning"] || ""
        }
      rescue JSON::ParserError => e
        {score: 0, reasoning: "Failed to parse: #{e.message}"}
      end

      def calculate_average_score(results)
        return 0.0 if results.nil? || results.empty?

        scores = results.map { |r| r["score"] }.compact
        return 0.0 if scores.empty?

        scores.sum / scores.length.to_f
      end
    end
  end
end
