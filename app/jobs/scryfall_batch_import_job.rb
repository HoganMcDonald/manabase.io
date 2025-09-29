# frozen_string_literal: true

class ScryfallBatchImportJob < ApplicationJob
  queue_as :low

  def perform(sync_id:, sync_type:, batch_number:, records:)
    @sync = ScryfallSync.find(sync_id)
    @sync_type = sync_type
    @batch_number = batch_number

    Rails.logger.info "Processing batch #{batch_number} with #{records.size} #{sync_type} records"

    case sync_type
    when "oracle_cards"
      process_oracle_cards(records)
    when "default_cards", "all_cards", "unique_artwork"
      process_card_printings(records)
    when "rulings"
      process_rulings(records)
    else
      Rails.logger.error "Unknown sync type: #{sync_type}"
    end

    Rails.logger.info "Completed batch #{batch_number} for #{sync_type}"
  rescue StandardError => e
    Rails.logger.error "Batch #{batch_number} failed for #{sync_type}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    @sync.increment!(:failed_batches)
    raise
  end

  private

  def process_oracle_cards(records)
    mapper = Scryfall::CardMapper.new

    records.each do |record|
      mapper.import_oracle_card(record)
    rescue StandardError => e
      Rails.logger.error "Failed to import oracle card #{record['oracle_id']}: #{e.message}"
    end
  end

  def process_card_printings(records)
    mapper = Scryfall::CardMapper.new

    records.each do |record|
      mapper.import_card_printing(record)
    rescue StandardError => e
      Rails.logger.error "Failed to import card printing #{record['id']}: #{e.message}"
    end
  end

  def process_rulings(records)
    mapper = Scryfall::RulingMapper.new

    records.each do |record|
      mapper.import_ruling(record)
    rescue StandardError => e
      Rails.logger.error "Failed to import ruling for #{record['oracle_id']}: #{e.message}"
    end
  end
end
