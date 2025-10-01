# frozen_string_literal: true

class AddErrorSummaryToScryfallSyncs < ActiveRecord::Migration[8.0]
  def change
    add_column :scryfall_syncs, :error_summary, :jsonb, default: {}
    add_column :scryfall_syncs, :invalid_uuid_count, :integer, default: 0
    add_column :scryfall_syncs, :warning_count, :integer, default: 0

    # Add indexes for monitoring
    add_index :scryfall_syncs, :invalid_uuid_count
    add_index :scryfall_syncs, :warning_count
  end
end
