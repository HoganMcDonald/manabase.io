# frozen_string_literal: true

class AddMissingScryfallFieldsToCards < ActiveRecord::Migration[8.0]
  def change
    # Add missing fields to cards table
    add_column :cards, :scryfall_id, :uuid, comment: "Scryfall's unique card ID"
    add_column :cards, :card_back_id, :uuid, comment: "ID of the card back for double-faced cards"
    add_column :cards, :game_changer, :boolean, default: false, comment: "Whether this card is a game changer"
    add_column :cards, :content_warning, :boolean, default: false, comment: "Whether this card has content warnings"
    add_column :cards, :variation_of, :uuid, comment: "ID of the card this is a variation of"

    # Add indexes for new fields
    add_index :cards, :scryfall_id, unique: true
    add_index :cards, :card_back_id
    add_index :cards, :variation_of

    # Add missing fields to card_printings table
    add_column :card_printings, :scryfall_id, :uuid, comment: "Scryfall's unique printing ID"
    add_column :card_printings, :card_back_id, :uuid, comment: "ID of the card back for this printing"
    add_column :card_printings, :content_warning, :boolean, default: false
    add_column :card_printings, :variation_of, :uuid
    add_column :card_printings, :purchase_uris, :jsonb, default: {}, comment: "Purchase links for this printing"
    add_column :card_printings, :related_uris, :jsonb, default: {}, comment: "Related URIs for this printing"

    # Add indexes for card_printings
    add_index :card_printings, :scryfall_id, unique: true
    add_index :card_printings, :card_back_id

    # Fix artist_ids to be jsonb array instead of single string
    remove_column :card_faces, :artist_id, :string
    add_column :card_faces, :artist_ids, :jsonb, default: [], comment: "Array of artist IDs"

    remove_column :card_printings, :artist_id, :string
    add_column :card_printings, :artist_ids, :jsonb, default: [], comment: "Array of artist IDs"

    # Add missing fields for card_sets if they don't exist
    unless column_exists?(:card_sets, :icon_svg_uri)
      add_column :card_sets, :icon_svg_uri, :string
    end

    unless column_exists?(:card_sets, :card_count)
      add_column :card_sets, :card_count, :integer
    end

    unless column_exists?(:card_sets, :parent_set_code)
      add_column :card_sets, :parent_set_code, :string
    end

    unless column_exists?(:card_sets, :block_code)
      add_column :card_sets, :block_code, :string
    end

    unless column_exists?(:card_sets, :block)
      add_column :card_sets, :block, :string
    end

    unless column_exists?(:card_sets, :foil_only)
      add_column :card_sets, :foil_only, :boolean, default: false
    end

    unless column_exists?(:card_sets, :nonfoil_only)
      add_column :card_sets, :nonfoil_only, :boolean, default: false
    end

    unless column_exists?(:card_sets, :tcgplayer_id)
      add_column :card_sets, :tcgplayer_id, :integer
    end

    # Update related_cards to use Scryfall IDs properly
    add_column :related_cards, :scryfall_id, :uuid, comment: "Scryfall's ID for the related card"
    add_index :related_cards, :scryfall_id

    # Add purchase URIs tracking to cards
    add_column :cards, :purchase_uris, :jsonb, default: {}, comment: "Purchase links (aggregated from printings)"
    add_column :cards, :related_uris, :jsonb, default: {}, comment: "Related URIs (aggregated)"
  end
end
