# frozen_string_literal: true

class OpenSearchCardUpdateJob < ApplicationJob
  queue_as :default

  def perform(card_id, action = "index")
    indexer = Search::CardIndexer.new

    case action.to_s
    when "index"
      card = Card.includes(:card_faces, :card_legalities, :card_printings).find(card_id)
      success = indexer.index_card(card)

      if success
        Rails.logger.debug("OpenSearch: Successfully indexed card #{card_id}")
      else
        Rails.logger.error("OpenSearch: Failed to index card #{card_id}")
      end
    when "delete"
      success = indexer.delete_card(card_id)

      if success
        Rails.logger.debug("OpenSearch: Successfully deleted card #{card_id}")
      else
        Rails.logger.error("OpenSearch: Failed to delete card #{card_id}")
      end
    else
      Rails.logger.error("OpenSearch: Unknown action '#{action}' for card #{card_id}")
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("OpenSearch: Card #{card_id} not found, skipping indexing")
  rescue StandardError => e
    Rails.logger.error("OpenSearch: Card update job failed for card #{card_id}: #{e.message}")
    raise
  end
end
