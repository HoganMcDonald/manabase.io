# frozen_string_literal: true

class OpenSearchReindexJob < ApplicationJob
  queue_as :default

  BATCH_SIZE = 500

  def perform(sync_id)
    sync = OpenSearchSync.find(sync_id)
    indexer = Search::CardIndexer.new

    # Start the sync
    sync.start_indexing!

    # Get total card count (only playable cards)
    total_cards = Card.joins(:card_legalities)
      .where(card_legalities: {status: ["legal", "restricted", "banned"]})
      .distinct
      .count
    sync.update!(total_cards: total_cards)

    Rails.logger.info("OpenSearch: Starting reindex of #{total_cards} cards")

    # Process cards in batches
    # Only index cards that are playable (legal, restricted, or banned in at least one format)
    # This excludes art cards, which are not_legal in all formats
    Card.joins(:card_legalities)
      .where(card_legalities: {status: ["legal", "restricted", "banned"]})
      .distinct
      .includes(:card_faces, :card_legalities, :card_printings)
      .find_in_batches(batch_size: BATCH_SIZE) do |batch|
      begin
        success = indexer.bulk_index(batch)

        if success
          sync.increment!(:indexed_cards, batch.size)

          # If embeddings were generated, mark cards with embeddings_generated_at
          if ENV["GENERATE_EMBEDDINGS"] == "true"
            # Only update cards that don't already have embeddings_generated_at
            # (unless FORCE_REGENERATE_EMBEDDINGS is true)
            cards_to_update = if ENV["FORCE_REGENERATE_EMBEDDINGS"] == "true"
              batch
            else
              batch.select { |card| card.embeddings_generated_at.nil? }
            end

            if cards_to_update.any?
              Card.where(id: cards_to_update.map(&:id)).update_all(embeddings_generated_at: Time.current)
            end
          end
        else
          sync.increment!(:failed_cards, batch.size)
        end
      rescue StandardError => e
        Rails.logger.error("OpenSearch: Batch indexing failed: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        sync.increment!(:failed_cards, batch.size)
      end
    end

    # Refresh the index to make changes searchable
    indexer.refresh_index

    # Mark sync as complete
    if sync.failed_cards.zero?
      sync.complete!
      Rails.logger.info("OpenSearch: Reindex completed successfully")
    else
      sync.update!(error_message: "#{sync.failed_cards} cards failed to index")
      sync.fail!
      Rails.logger.warn("OpenSearch: Reindex completed with #{sync.failed_cards} failures")
    end
  rescue StandardError => e
    Rails.logger.error("OpenSearch: Reindex job failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    sync.update!(error_message: e.message)
    sync.fail!
    raise
  end
end
