# frozen_string_literal: true

class CreateScryfallSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :scryfall_syncs do |t|
      t.string :sync_type, null: false
      t.string :status, null: false, default: "pending"
      t.string :version
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message
      t.bigint :file_size
      t.string :download_uri
      t.string :file_path

      t.timestamps
    end

    add_index :scryfall_syncs, :sync_type
    add_index :scryfall_syncs, :status
    add_index :scryfall_syncs, [:sync_type, :version], unique: true
  end
end
