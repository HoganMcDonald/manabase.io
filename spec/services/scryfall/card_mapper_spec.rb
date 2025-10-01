# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scryfall::CardMapper do
  let(:mapper) { described_class.new }

  describe "#import_oracle_card" do
    let(:oracle_data) do
      {
        "id" => "12345678-1234-1234-1234-123456789abc",
        "oracle_id" => "98765432-9876-9876-9876-987654321cba",
        "name" => "Test Card",
        "lang" => "en",
        "released_at" => "2023-01-01",
        "uri" => "https://api.scryfall.com/cards/12345678",
        "scryfall_uri" => "https://scryfall.com/card/test",
        "layout" => "normal",
        "highres_image" => true,
        "image_status" => "highres_scan",
        "cmc" => 3.0,
        "type_line" => "Creature — Test",
        "oracle_text" => "Test ability",
        "mana_cost" => "{2}{U}",
        "power" => "2",
        "toughness" => "3",
        "colors" => ["U"],
        "color_identity" => ["U"],
        "keywords" => ["Flying"],
        "games" => ["paper", "mtgo", "arena"],
        "reserved" => false,
        "foil" => true,
        "nonfoil" => true,
        "card_back_id" => "0aeebaf5-8c7d-4636-9e82-8c27447861f7",
        "game_changer" => true,
        "content_warning" => false,
        "variation_of" => nil,
        "purchase_uris" => {
          "tcgplayer" => "https://tcgplayer.com/test",
          "cardmarket" => "https://cardmarket.com/test"
        },
        "related_uris" => {
          "gatherer" => "https://gatherer.wizards.com/test"
        },
        "set" => "tst",
        "set_name" => "Test Set",
        "set_type" => "expansion",
        "legalities" => {
          "standard" => "legal",
          "commander" => "legal"
        },
        "all_parts" => [
          {
            "id" => "abcdef12-3456-7890-abcd-ef1234567890",
            "component" => "token",
            "name" => "Test Token",
            "type_line" => "Token Creature — Test",
            "uri" => "https://api.scryfall.com/cards/related-1"
          }
        ],
        "card_faces" => [
          {
            "name" => "Front Face",
            "mana_cost" => "{2}{U}",
            "type_line" => "Creature",
            "oracle_text" => "Front text",
            "colors" => ["U"],
            "power" => "2",
            "toughness" => "3",
            "artist" => "Test Artist",
            "artist_ids" => ["artist-id-1", "artist-id-2"],
            "illustration_id" => "illustration-1",
            "image_uris" => {
              "normal" => "https://example.com/front.jpg"
            }
          }
        ]
      }
    end

    it "creates a card with all fields including new ones" do
      card = mapper.import_oracle_card(oracle_data)

      expect(card).to be_persisted
      expect(card.scryfall_id).to eq("12345678-1234-1234-1234-123456789abc")
      expect(card.oracle_id).to eq("98765432-9876-9876-9876-987654321cba")
      expect(card.name).to eq("Test Card")
      expect(card.card_back_id).to eq("0aeebaf5-8c7d-4636-9e82-8c27447861f7")
      expect(card.game_changer).to be true
      expect(card.content_warning).to be false
      expect(card.variation_of).to be_nil
      expect(card.purchase_uris).to eq({
        "tcgplayer" => "https://tcgplayer.com/test",
        "cardmarket" => "https://cardmarket.com/test"
      })
      expect(card.related_uris).to eq({
        "gatherer" => "https://gatherer.wizards.com/test"
      })
    end

    it "creates card faces with artist_ids array" do
      card = mapper.import_oracle_card(oracle_data)

      expect(card.card_faces.count).to eq(1)
      face = card.card_faces.first
      expect(face.artist).to eq("Test Artist")
      expect(face.artist_ids).to eq(["artist-id-1", "artist-id-2"])
    end

    it "creates related cards with scryfall_id" do
      card = mapper.import_oracle_card(oracle_data)

      expect(card.related_cards.count).to eq(1)
      related = card.related_cards.first
      expect(related.scryfall_id).to eq("abcdef12-3456-7890-abcd-ef1234567890")
      expect(related.related_card_id).to eq("abcdef12-3456-7890-abcd-ef1234567890")
      expect(related.component).to eq("token")
      expect(related.name).to eq("Test Token")
    end

    it "creates or updates card set with new fields" do
      card = mapper.import_oracle_card(oracle_data)

      set = CardSet.find_by(code: "tst")
      expect(set).to be_present
      expect(set.name).to eq("Test Set")
      expect(set.set_type).to eq("expansion")
    end
  end

  describe "#import_card_printing" do
    let(:printing_data) do
      {
        "id" => "87654321-4321-4321-4321-210987654321",
        "oracle_id" => "98765432-9876-9876-9876-987654321cba",
        "name" => "Test Card",
        "set" => "tst",
        "set_name" => "Test Set",
        "set_type" => "expansion",
        "collector_number" => "123",
        "rarity" => "rare",
        "artist" => "Test Artist",
        "artist_ids" => ["artist-id-1"],
        "border_color" => "black",
        "frame" => "2015",
        "full_art" => false,
        "textless" => false,
        "booster" => true,
        "prices" => {
          "usd" => "5.00",
          "eur" => "4.50"
        },
        "image_uris" => {
          "normal" => "https://example.com/card.jpg"
        },
        "finishes" => ["nonfoil", "foil"],
        "card_back_id" => "11111111-2222-3333-4444-555555555555",
        "content_warning" => false,
        "purchase_uris" => {
          "tcgplayer" => "https://tcgplayer.com/product/12345"
        },
        "related_uris" => {
          "edhrec" => "https://edhrec.com/cards/test-card"
        },
        "cmc" => 3.0,
        "type_line" => "Creature — Test",
        "layout" => "normal",
        "image_status" => "highres_scan"
      }
    end

    it "creates a printing with all new fields" do
      printing = mapper.import_card_printing(printing_data)

      expect(printing).to be_persisted
      expect(printing.scryfall_id).to eq("87654321-4321-4321-4321-210987654321")
      expect(printing.artist_ids).to eq(["artist-id-1"])
      expect(printing.card_back_id).to eq("11111111-2222-3333-4444-555555555555")
      expect(printing.content_warning).to be false
      expect(printing.purchase_uris).to eq({
        "tcgplayer" => "https://tcgplayer.com/product/12345"
      })
      expect(printing.related_uris).to eq({
        "edhrec" => "https://edhrec.com/cards/test-card"
      })
    end
  end
end
