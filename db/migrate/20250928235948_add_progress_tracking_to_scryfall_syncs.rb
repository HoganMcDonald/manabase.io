# frozen_string_literal: true

class AddProgressTrackingToScryfallSyncs < ActiveRecord::Migration[8.0]
  def change
    add_column :scryfall_syncs, :total_records, :integer
    add_column :scryfall_syncs, :processed_records, :integer, default: 0
    add_column :scryfall_syncs, :failed_batches, :integer, default: 0
    add_column :scryfall_syncs, :processing_status, :string
    add_column :scryfall_syncs, :processing_started_at, :datetime
    add_column :scryfall_syncs, :processing_completed_at, :datetime
    add_column :scryfall_syncs, :last_processed_batch, :integer
    add_column :scryfall_syncs, :batch_size, :integer, default: 500

    add_index :scryfall_syncs, :processing_status
  end
end
