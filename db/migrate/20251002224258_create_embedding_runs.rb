# frozen_string_literal: true

class CreateEmbeddingRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :embedding_runs do |t|
      t.string :status
      t.integer :total_cards
      t.integer :processed_cards
      t.integer :failed_cards
      t.integer :batch_size
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message

      t.timestamps
    end
  end
end
