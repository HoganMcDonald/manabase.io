# frozen_string_literal: true

class AddFailureLogsToScryfallSyncs < ActiveRecord::Migration[8.0]
  def change
    add_column :scryfall_syncs, :failure_logs, :jsonb, default: []
    add_index :scryfall_syncs, :failure_logs, using: :gin
  end
end
