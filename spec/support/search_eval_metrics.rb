# frozen_string_literal: true

module SearchEvalMetrics
  # Calculate Precision@K - what fraction of top K results are relevant?
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @param k [Integer] Number of top results to consider
  # @return [Float] Precision score between 0.0 and 1.0
  def self.precision_at_k(results, expected, k = 10)
    return 0.0 if results.empty? || expected.empty?

    top_k = results.first(k)
    relevant_count = top_k.count { |result| expected.include?(result) }
    relevant_count.to_f / k
  end

  # Calculate Recall@K - what fraction of relevant results appear in top K?
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @param k [Integer] Number of top results to consider
  # @return [Float] Recall score between 0.0 and 1.0
  def self.recall_at_k(results, expected, k = 10)
    return 0.0 if results.empty? || expected.empty?

    top_k = results.first(k)
    relevant_count = top_k.count { |result| expected.include?(result) }
    relevant_count.to_f / expected.length
  end

  # Calculate Mean Reciprocal Rank - how quickly does first relevant result appear?
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @return [Float] MRR score between 0.0 and 1.0
  def self.mean_reciprocal_rank(results, expected)
    return 0.0 if results.empty? || expected.empty?

    first_relevant_index = results.index { |result| expected.include?(result) }
    return 0.0 if first_relevant_index.nil?

    1.0 / (first_relevant_index + 1)
  end

  # Calculate Normalized Discounted Cumulative Gain
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @param k [Integer] Number of top results to consider
  # @return [Float] NDCG score between 0.0 and 1.0
  def self.ndcg_at_k(results, expected, k = 10)
    return 0.0 if results.empty? || expected.empty?

    # Calculate DCG (Discounted Cumulative Gain)
    dcg = results.first(k).each_with_index.sum do |result, idx|
      relevance = expected.include?(result) ? 1 : 0
      relevance / Math.log2(idx + 2) # +2 because log2(1) = 0
    end

    # Calculate ideal DCG (if results were perfectly ordered)
    ideal_results = expected + (results - expected)
    ideal_dcg = ideal_results.first(k).each_with_index.sum do |result, idx|
      relevance = expected.include?(result) ? 1 : 0
      relevance / Math.log2(idx + 2)
    end

    return 0.0 if ideal_dcg.zero?

    dcg / ideal_dcg
  end

  # Calculate all metrics for a single query
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @param k [Integer] Number of top results to consider
  # @return [Hash] All metrics
  def self.calculate_all(results, expected, k = 10)
    {
      precision_at_k: precision_at_k(results, expected, k),
      recall_at_k: recall_at_k(results, expected, k),
      mrr: mean_reciprocal_rank(results, expected),
      ndcg_at_k: ndcg_at_k(results, expected, k),
      first_relevant_rank: first_relevant_rank(results, expected),
      total_relevant_found: total_relevant_found(results, expected, k)
    }
  end

  # Get the rank of the first relevant result (1-indexed)
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @return [Integer, nil] Rank of first relevant result, or nil if none found
  def self.first_relevant_rank(results, expected)
    first_index = results.index { |result| expected.include?(result) }
    first_index ? first_index + 1 : nil
  end

  # Count how many relevant results were found in top K
  # @param results [Array<String>] Ordered list of result names
  # @param expected [Array<String>] List of relevant result names
  # @param k [Integer] Number of top results to consider
  # @return [Integer] Number of relevant results found
  def self.total_relevant_found(results, expected, k = 10)
    results.first(k).count { |result| expected.include?(result) }
  end

  # Calculate aggregate metrics across multiple queries
  # @param query_metrics [Array<Hash>] Array of per-query metrics
  # @return [Hash] Aggregated metrics
  def self.aggregate_metrics(query_metrics)
    return {} if query_metrics.empty?

    {
      avg_precision: average(query_metrics, :precision_at_k),
      avg_recall: average(query_metrics, :recall_at_k),
      avg_mrr: average(query_metrics, :mrr),
      avg_ndcg: average(query_metrics, :ndcg_at_k),
      median_first_rank: median(query_metrics.map { |m| m[:first_relevant_rank] }.compact),
      total_queries: query_metrics.length,
      queries_with_no_results: query_metrics.count { |m| m[:first_relevant_rank].nil? }
    }
  end

  private

  def self.average(metrics, key)
    values = metrics.map { |m| m[key] }.compact
    return 0.0 if values.empty?

    values.sum / values.length.to_f
  end

  def self.median(values)
    return nil if values.empty?

    sorted = values.sort
    mid = sorted.length / 2
    sorted.length.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end
end
