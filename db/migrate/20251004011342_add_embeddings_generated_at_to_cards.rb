# frozen_string_literal: true

class AddEmbeddingsGeneratedAtToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :embeddings_generated_at, :datetime
  end
end
