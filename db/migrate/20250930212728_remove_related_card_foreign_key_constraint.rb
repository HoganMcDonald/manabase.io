# frozen_string_literal: true

class RemoveRelatedCardForeignKeyConstraint < ActiveRecord::Migration[8.0]
  def change
    # Remove the foreign key constraint on related_card_id
    # This allows us to store references to cards that don't exist yet
    # (e.g., tokens, cards from future sets, etc.)
    remove_foreign_key :related_cards, column: :related_card_id
  end
end
