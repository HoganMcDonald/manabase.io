# frozen_string_literal: true

class SearchEvalJob < ApplicationJob
  queue_as :default

  def perform(search_eval_id)
    search_eval = SearchEval.find(search_eval_id)
    search_eval.start_running!

    begin
      # Load golden dataset
      golden_dataset = YAML.load_file(Rails.root.join("spec/fixtures/search_evals.yml"))
      search_eval.update!(total_queries: golden_dataset.length)

      # Initialize search service
      search_service = Search::CardSearch.new
      eval_type = search_eval.eval_type || "keyword" # Default to keyword mode
      use_llm_judge = search_eval.use_llm_judge || false

      # Run evaluations
      all_results = []
      completed_count = 0
      failed_count = 0

      golden_dataset.each do |test_case|
        begin
          query = test_case["query"]
          expected_results = test_case["expected_results"] || []

          # Perform search
          results = search_service.search(
            query,
            search_mode: eval_type,
            per_page: 20
          )

          result_names = results[:results].map { |r| r["name"] || r[:name] }

          # Calculate metrics
          metrics = SearchEvalMetrics.calculate_all(result_names, expected_results, 10)

          # Optional: Use LLM-as-judge for semantic queries
          llm_eval = if use_llm_judge && test_case["relevance_threshold"]
            Search::EvalJudge.evaluate_results(
              query,
              results[:results],
              expected_cards: expected_results
            )
          end

          all_results << {
            query: query,
            description: test_case["description"],
            expected: expected_results,
            results: result_names.first(10),
            metrics: metrics,
            llm_evaluation: llm_eval
          }

          completed_count += 1
        rescue StandardError => e
          Rails.logger.error("Eval query failed for '#{test_case["query"]}': #{e.message}")
          failed_count += 1
        end

        # Update progress periodically
        search_eval.update!(
          completed_queries: completed_count,
          failed_queries: failed_count
        )
      end

      # Calculate aggregate metrics
      all_metrics = all_results.map { |r| r[:metrics] }
      aggregate = SearchEvalMetrics.aggregate_metrics(all_metrics)

      # Update final results
      search_eval.update!(
        avg_precision: aggregate[:avg_precision],
        avg_recall: aggregate[:avg_recall],
        avg_mrr: aggregate[:avg_mrr],
        avg_ndcg: aggregate[:avg_ndcg],
        results: all_results.to_json
      )

      search_eval.complete!
    rescue StandardError => e
      Rails.logger.error("Search eval job failed: #{e.message}")
      Rails.logger.error(e.backtrace.first(10).join("\n"))
      search_eval.update!(error_message: e.message)
      search_eval.fail!
    end
  end
end
