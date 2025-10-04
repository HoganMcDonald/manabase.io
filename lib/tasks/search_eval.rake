# frozen_string_literal: true

namespace :search do
  namespace :eval do
    desc "Run search quality evaluation suite"
    task run: :environment do
      puts "Running search quality evaluations..."
      puts "This may take a few minutes depending on your dataset size."
      puts

      # Set environment variable to enable eval tests
      ENV["RUN_SEARCH_EVALS"] = "true"

      # Run the eval specs
      require "rspec/core"

      config = RSpec::Core::ConfigurationOptions.new([
        "spec/evals/search_quality_spec.rb",
        "--format", "documentation",
        "--color"
      ])

      runner = RSpec::Core::Runner.new(config)
      exit_code = runner.run($stderr, $stdout)

      exit(exit_code) if exit_code != 0
    end

    desc "Run search evals with LLM judge enabled"
    task with_judge: :environment do
      puts "Running search quality evaluations WITH LLM-as-judge..."
      puts "This will use OpenAI API and may take longer."
      puts

      ENV["RUN_SEARCH_EVALS"] = "true"
      ENV["USE_LLM_JUDGE"] = "true"

      require "rspec/core"

      config = RSpec::Core::ConfigurationOptions.new([
        "spec/evals/search_quality_spec.rb",
        "--format", "documentation",
        "--color"
      ])

      runner = RSpec::Core::Runner.new(config)
      exit_code = runner.run($stderr, $stdout)

      exit(exit_code) if exit_code != 0
    end

    desc "Generate detailed evaluation report"
    task report: :environment do
      require "yaml"
      require "csv"
      require_relative "../../spec/support/search_eval_metrics"

      puts "Generating search quality report..."

      golden_dataset = YAML.load_file(Rails.root.join("spec/fixtures/search_evals.yml"))
      search_service = Search::CardSearch.new

      timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
      report_file = Rails.root.join("tmp", "search_eval_report_#{timestamp}.md")
      csv_file = Rails.root.join("tmp", "search_eval_results_#{timestamp}.csv")

      # Run evaluations
      results = []
      modes = %w[keyword semantic hybrid]

      golden_dataset.each_with_index do |test_case, idx|
        print "\rProcessing query #{idx + 1}/#{golden_dataset.length}..."

        query = test_case["query"]
        expected = test_case["expected_results"] || []

        mode_results = {}

        modes.each do |mode|
          search_results = search_service.search(query, search_mode: mode, per_page: 20)
          result_names = search_results[:results].map { |r| r["name"] || r[:name] }
          metrics = SearchEvalMetrics.calculate_all(result_names, expected, 10)

          mode_results[mode] = {
            metrics: metrics,
            results: result_names.first(10)
          }
        end

        results << {
          query: query,
          description: test_case["description"],
          expected: expected,
          by_mode: mode_results
        }
      end

      puts "\nGenerating report..."

      # Generate Markdown report
      File.open(report_file, "w") do |f|
        write_markdown_report(f, results, modes)
      end

      # Generate CSV results
      CSV.open(csv_file, "w") do |csv|
        write_csv_results(csv, results, modes)
      end

      puts "\nReport generated:"
      puts "  Markdown: #{report_file}"
      puts "  CSV:      #{csv_file}"
      puts "\nAppending to history file..."

      # Append to history
      append_to_history(results, modes)

      puts "Done!"
    end

    desc "Show evaluation history"
    task history: :environment do
      history_file = Rails.root.join("tmp", "search_eval_history.csv")

      unless File.exist?(history_file)
        puts "No evaluation history found."
        puts "Run 'rake search:eval:report' to generate your first report."
        exit
      end

      puts "Search Evaluation History"
      puts "=" * 80
      puts

      # Read and display history
      CSV.foreach(history_file, headers: true) do |row|
        puts "#{row['timestamp']} - #{row['mode'].capitalize} Mode"
        puts "  Precision@10: #{row['avg_precision']}"
        puts "  Recall@10:    #{row['avg_recall']}"
        puts "  MRR:          #{row['avg_mrr']}"
        puts "  NDCG@10:      #{row['avg_ndcg']}"
        puts
      end
    end
  end

  # Convenience alias
  desc "Run search quality evaluation (alias for search:eval:run)"
  task eval: "eval:run"
end

private

def write_markdown_report(file, results, modes)
  file.puts "# Search Quality Evaluation Report"
  file.puts
  file.puts "**Generated:** #{Time.current.strftime("%Y-%m-%d %H:%M:%S")}"
  file.puts "**Total Queries:** #{results.length}"
  file.puts
  file.puts "---"
  file.puts

  # Summary by mode
  file.puts "## Summary by Search Mode"
  file.puts

  modes.each do |mode|
    file.puts "### #{mode.capitalize} Search"
    file.puts

    mode_metrics = results.map { |r| r[:by_mode][mode][:metrics] }
    aggregate = SearchEvalMetrics.aggregate_metrics(mode_metrics)

    file.puts "| Metric | Value |"
    file.puts "|--------|-------|"
    file.puts "| Average Precision@10 | #{aggregate[:avg_precision].round(3)} |"
    file.puts "| Average Recall@10 | #{aggregate[:avg_recall].round(3)} |"
    file.puts "| Average MRR | #{aggregate[:avg_mrr].round(3)} |"
    file.puts "| Average NDCG@10 | #{aggregate[:avg_ndcg].round(3)} |"
    file.puts "| Median First Rank | #{aggregate[:median_first_rank]&.round(1) || 'N/A'} |"
    file.puts
  end

  file.puts "---"
  file.puts

  # Detailed results per query
  file.puts "## Detailed Results"
  file.puts

  results.each do |result|
    file.puts "### Query: \"#{result[:query]}\""
    file.puts
    file.puts "*#{result[:description]}*"
    file.puts
    file.puts "**Expected cards:** #{result[:expected].join(", ")}" if result[:expected].any?
    file.puts

    modes.each do |mode|
      mode_data = result[:by_mode][mode]
      metrics = mode_data[:metrics]

      file.puts "#### #{mode.capitalize} Mode"
      file.puts
      file.puts "- First relevant rank: #{metrics[:first_relevant_rank] || 'N/A'}"
      file.puts "- Total relevant found: #{metrics[:total_relevant_found]}/#{result[:expected].length}"
      file.puts "- Precision@10: #{metrics[:precision_at_k].round(3)}"
      file.puts "- MRR: #{metrics[:mrr].round(3)}"
      file.puts
      file.puts "Top 5 results: #{mode_data[:results].first(5).join(", ")}"
      file.puts
    end

    file.puts "---"
    file.puts
  end
end

def write_csv_results(csv, results, modes)
  # Header
  csv << [
    "query",
    "description",
    "expected_count",
    "mode",
    "precision_at_10",
    "recall_at_10",
    "mrr",
    "ndcg_at_10",
    "first_relevant_rank",
    "relevant_found",
    "top_5_results"
  ]

  # Data rows
  results.each do |result|
    modes.each do |mode|
      mode_data = result[:by_mode][mode]
      metrics = mode_data[:metrics]

      csv << [
        result[:query],
        result[:description],
        result[:expected].length,
        mode,
        metrics[:precision_at_k].round(3),
        metrics[:recall_at_k].round(3),
        metrics[:mrr].round(3),
        metrics[:ndcg_at_k].round(3),
        metrics[:first_relevant_rank] || "",
        metrics[:total_relevant_found],
        mode_data[:results].first(5).join("; ")
      ]
    end
  end
end

def append_to_history(results, modes)
  history_file = Rails.root.join("tmp", "search_eval_history.csv")
  timestamp = Time.current.strftime("%Y-%m-%d %H:%M:%S")

  # Create file with headers if it doesn't exist
  unless File.exist?(history_file)
    CSV.open(history_file, "w") do |csv|
      csv << %w[timestamp mode avg_precision avg_recall avg_mrr avg_ndcg median_first_rank queries_no_results total_queries]
    end
  end

  # Append results for each mode
  CSV.open(history_file, "a") do |csv|
    modes.each do |mode|
      mode_metrics = results.map { |r| r[:by_mode][mode][:metrics] }
      aggregate = SearchEvalMetrics.aggregate_metrics(mode_metrics)

      csv << [
        timestamp,
        mode,
        aggregate[:avg_precision].round(3),
        aggregate[:avg_recall].round(3),
        aggregate[:avg_mrr].round(3),
        aggregate[:avg_ndcg].round(3),
        aggregate[:median_first_rank]&.round(1),
        aggregate[:queries_with_no_results],
        aggregate[:total_queries]
      ]
    end
  end
end
