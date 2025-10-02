# frozen_string_literal: true

require "opensearch"

OpenSearch::Client.new(
  host: ENV.fetch("OPENSEARCH_URL", "http://localhost:9200"),
  log: Rails.env.development?,
  transport_options: {
    request: {timeout: 30}
  }
)

# Make client available globally
$OPENSEARCH_CLIENT = OpenSearch::Client.new(
  host: ENV.fetch("OPENSEARCH_URL", "http://localhost:9200"),
  log: Rails.env.development?,
  transport_options: {
    request: {timeout: 30}
  }
)
