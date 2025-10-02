# frozen_string_literal: true

module Search
  class Base
    INDEX_NAME = "cards"

    private

    def client
      @client ||= $OPENSEARCH_CLIENT
    end

    def index_exists?
      client.indices.exists?(index: INDEX_NAME)
    rescue StandardError => e
      Rails.logger.error("OpenSearch error checking index existence: #{e.message}")
      false
    end

    def index_name
      INDEX_NAME
    end
  end
end
