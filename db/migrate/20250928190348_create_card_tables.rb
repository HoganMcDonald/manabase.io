# frozen_string_literal: true

class CreateCardTables < ActiveRecord::Migration[8.0]
  def change
    # Enable required extensions
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    # Card Sets table
    create_table :card_sets, id: :uuid do |t|
      t.string :code, null: false, index: {unique: true}
      t.string :name, null: false
      t.string :set_type, null: false
      t.date :released_at
      t.string :block
      t.string :block_code
      t.integer :card_count
      t.boolean :digital, default: false
      t.boolean :foil_only, default: false
      t.boolean :nonfoil_only, default: false
      t.string :icon_svg_uri
      t.string :scryfall_uri
      t.string :uri
      t.string :search_uri

      t.timestamps

      t.index :released_at
      t.index :set_type
    end

    # Main Cards table (Oracle data)
    create_table :cards, id: :uuid do |t|
      t.uuid :oracle_id, null: false, index: {unique: true}
      t.string :name, null: false, index: true
      t.string :lang, default: "en"
      t.date :released_at
      t.string :uri
      t.string :scryfall_uri
      t.string :layout, null: false
      t.boolean :highres_image, default: true
      t.string :image_status, null: false

      # Gameplay attributes
      t.float :cmc, null: false
      t.string :type_line, null: false
      t.text :oracle_text
      t.string :mana_cost
      t.string :power
      t.string :toughness
      t.string :loyalty
      t.string :life_modifier
      t.string :hand_modifier

      # Colors and identity (JSONB arrays)
      t.jsonb :colors, default: []
      t.jsonb :color_identity, default: []
      t.jsonb :color_indicator, default: []
      t.jsonb :produced_mana, default: []

      # Keywords and games (JSONB arrays)
      t.jsonb :keywords, default: []
      t.jsonb :games, default: []

      # Flags
      t.boolean :reserved, default: false
      t.boolean :foil, default: true
      t.boolean :nonfoil, default: true
      t.boolean :oversized, default: false
      t.boolean :promo, default: false
      t.boolean :reprint, default: false
      t.boolean :variation, default: false
      t.boolean :digital, default: false
      t.boolean :full_art, default: false
      t.boolean :textless, default: false
      t.boolean :booster, default: true
      t.boolean :story_spotlight, default: false

      # External IDs
      t.integer :edhrec_rank
      t.integer :penny_rank
      t.integer :arena_id
      t.integer :mtgo_id
      t.integer :mtgo_foil_id
      t.integer :tcgplayer_id
      t.integer :tcgplayer_etched_id
      t.integer :cardmarket_id

      # URIs and related data
      t.string :prints_search_uri
      t.string :rulings_uri
      t.string :scryfall_set_uri

      t.timestamps

      # Indexes for common queries
      t.index :cmc
      t.index :type_line
      t.index :oracle_text, using: :gin, opclass: :gin_trgm_ops
      t.index :colors, using: :gin
      t.index :color_identity, using: :gin
      t.index :keywords, using: :gin
      t.index :released_at
    end

    # Card Printings table (links cards to sets with print-specific data)
    create_table :card_printings, id: :uuid do |t|
      t.references :card, type: :uuid, null: false, foreign_key: true
      t.references :card_set, type: :uuid, null: false, foreign_key: true

      t.string :collector_number, null: false
      t.string :rarity, null: false
      t.string :watermark
      t.string :printed_name
      t.text :printed_text
      t.string :printed_type_line
      t.string :artist
      t.string :artist_id
      t.string :illustration_id
      t.string :border_color, null: false
      t.string :frame
      t.string :security_stamp
      t.boolean :full_art, default: false
      t.boolean :textless, default: false
      t.boolean :booster, default: true
      t.boolean :story_spotlight, default: false
      t.boolean :promo, default: false
      t.boolean :reprint, default: false

      # Prices stored as JSONB
      t.jsonb :prices, default: {}

      # Image URIs stored as JSONB
      t.jsonb :image_uris, default: {}

      # Preview information
      t.jsonb :preview

      # Promo types array
      t.jsonb :promo_types, default: []

      # Frame effects array
      t.jsonb :frame_effects, default: []

      # Finishes array
      t.jsonb :finishes, default: []

      # Multiverse IDs array
      t.jsonb :multiverse_ids, default: []

      # Attraction lights for Unfinity
      t.jsonb :attraction_lights, default: []

      t.timestamps

      t.index [:card_id, :card_set_id, :collector_number], unique: true, name: "idx_printings_unique"
      t.index :rarity
      t.index :artist
      t.index :prices, using: :gin
    end

    # Card Faces table (for multi-faced cards)
    create_table :card_faces do |t|
      t.references :card, type: :uuid, null: false, foreign_key: true
      t.integer :face_index, null: false

      t.string :name, null: false
      t.string :mana_cost
      t.string :type_line
      t.text :oracle_text
      t.jsonb :colors, default: []
      t.jsonb :color_indicator
      t.string :power
      t.string :toughness
      t.string :loyalty
      t.string :defense
      t.text :flavor_text
      t.string :artist
      t.string :artist_id
      t.string :illustration_id
      t.jsonb :image_uris, default: {}
      t.string :flavor_name
      t.string :printed_name
      t.text :printed_text
      t.string :printed_type_line
      t.string :watermark
      t.string :layout

      t.timestamps

      t.index [:card_id, :face_index], unique: true
      t.index :name
    end

    # Card Rulings table
    create_table :card_rulings do |t|
      t.uuid :oracle_id, null: false, index: true
      t.string :source, null: false
      t.date :published_at, null: false
      t.text :comment, null: false

      t.timestamps

      t.index :published_at
    end

    # Card Legalities table
    create_table :card_legalities do |t|
      t.references :card, type: :uuid, null: false, foreign_key: true
      t.string :format, null: false
      t.string :status, null: false

      t.timestamps

      t.index [:card_id, :format], unique: true
      t.index [:format, :status]
    end

    # Related Cards table (many-to-many)
    create_table :related_cards do |t|
      t.references :card, type: :uuid, null: false, foreign_key: true
      t.uuid :related_card_id, null: false
      t.string :component, null: false # token, meld_part, combo_piece, etc
      t.string :name, null: false
      t.string :type_line, null: false
      t.string :uri

      t.timestamps

      t.index [:card_id, :related_card_id, :component], unique: true, name: "idx_related_unique"
      t.index :related_card_id
    end

    # Add foreign key for related_cards
    add_foreign_key :related_cards, :cards, column: :related_card_id
  end
end
