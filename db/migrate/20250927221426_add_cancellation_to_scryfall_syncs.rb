# frozen_string_literal: true

class AddCancellationToScryfallSyncs < ActiveRecord::Migration[8.0]
  def change
    add_column :scryfall_syncs, :cancelled_at, :datetime

    # Update the status column to include 'cancelled' as a valid value
    # Since we're using a string column, we just need to update the model validations
    # No database change needed for the status enum itself
  end
end
