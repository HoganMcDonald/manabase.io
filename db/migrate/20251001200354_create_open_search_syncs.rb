# frozen_string_literal: true

class CreateOpenSearchSyncs < ActiveRecord::Migration[8.0]
  def change
    create_table :open_search_syncs do |t|
      t.string :status, null: false, default: "pending"
      t.integer :total_cards, default: 0
      t.integer :indexed_cards, default: 0
      t.integer :failed_cards, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message

      t.timestamps
    end

    add_index :open_search_syncs, :status
    add_index :open_search_syncs, :created_at
  end
end
