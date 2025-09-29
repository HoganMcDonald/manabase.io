# frozen_string_literal: true

module Scryfall
  class CardMapper
    def import_oracle_card(data)
      # First, ensure the set exists
      set = find_or_create_set(data)

      # Create or update the main card (oracle data)
      card = Card.find_or_initialize_by(oracle_id: data["oracle_id"])

      card.assign_attributes(
        name: data["name"],
        lang: data["lang"] || "en",
        released_at: data["released_at"],
        uri: data["uri"],
        scryfall_uri: data["scryfall_uri"],
        layout: data["layout"],
        highres_image: data["highres_image"],
        image_status: data["image_status"],
        cmc: data["cmc"] || 0,
        type_line: data["type_line"],
        oracle_text: data["oracle_text"],
        mana_cost: data["mana_cost"],
        power: data["power"],
        toughness: data["toughness"],
        loyalty: data["loyalty"],
        life_modifier: data["life_modifier"],
        hand_modifier: data["hand_modifier"],
        colors: data["colors"] || [],
        color_identity: data["color_identity"] || [],
        color_indicator: data["color_indicator"],
        produced_mana: data["produced_mana"],
        keywords: data["keywords"] || [],
        games: data["games"] || [],
        reserved: data["reserved"] || false,
        foil: data["foil"],
        nonfoil: data["nonfoil"],
        oversized: data["oversized"] || false,
        promo: data["promo"] || false,
        reprint: data["reprint"] || false,
        variation: data["variation"] || false,
        digital: data["digital"] || false,
        full_art: data["full_art"] || false,
        textless: data["textless"] || false,
        booster: data["booster"] || true,
        story_spotlight: data["story_spotlight"] || false,
        edhrec_rank: data["edhrec_rank"],
        penny_rank: data["penny_rank"],
        arena_id: data["arena_id"],
        mtgo_id: data["mtgo_id"],
        mtgo_foil_id: data["mtgo_foil_id"],
        tcgplayer_id: data["tcgplayer_id"],
        tcgplayer_etched_id: data["tcgplayer_etched_id"],
        cardmarket_id: data["cardmarket_id"],
        prints_search_uri: data["prints_search_uri"],
        rulings_uri: data["rulings_uri"],
        scryfall_set_uri: data["scryfall_set_uri"]
      )

      card.save!

      # Import card faces if present
      import_card_faces(card, data["card_faces"]) if data["card_faces"]

      # Import legalities
      import_legalities(card, data["legalities"]) if data["legalities"]

      # Import related cards
      import_related_cards(card, data["all_parts"]) if data["all_parts"]

      card
    end

    def import_card_printing(data)
      # Ensure set exists
      set = find_or_create_set(data)

      # Find or create the oracle card first
      card = Card.find_or_initialize_by(oracle_id: data["oracle_id"])

      # Update card with oracle data if this is the first time we see it
      if card.new_record?
        import_oracle_card(data)
        card.reload
      end

      # Create the printing
      printing = CardPrinting.find_or_initialize_by(
        card_id: card.id,
        card_set_id: set.id,
        collector_number: data["collector_number"]
      )

      printing.assign_attributes(
        rarity: data["rarity"],
        watermark: data["watermark"],
        printed_name: data["printed_name"],
        printed_text: data["printed_text"],
        printed_type_line: data["printed_type_line"],
        artist: data["artist"],
        artist_id: data["artist_ids"]&.first,
        illustration_id: data["illustration_id"],
        border_color: data["border_color"],
        frame: data["frame"],
        security_stamp: data["security_stamp"],
        full_art: data["full_art"] || false,
        textless: data["textless"] || false,
        booster: data["booster"] || true,
        story_spotlight: data["story_spotlight"] || false,
        promo: data["promo"] || false,
        reprint: data["reprint"] || false,
        prices: data["prices"] || {},
        image_uris: data["image_uris"] || {},
        preview: data["preview"],
        promo_types: data["promo_types"] || [],
        frame_effects: data["frame_effects"] || [],
        finishes: data["finishes"] || [],
        multiverse_ids: data["multiverse_ids"] || [],
        attraction_lights: data["attraction_lights"] || []
      )

      printing.save!
      printing
    end

    private

    def find_or_create_set(data)
      CardSet.find_or_create_by(code: data["set"]) do |set|
        set.name = data["set_name"]
        set.set_type = data["set_type"]
        set.released_at = data["released_at"]
        set.scryfall_uri = data["scryfall_set_uri"]
        set.uri = data["set_uri"]
        set.search_uri = data["set_search_uri"]
        set.digital = data["digital"] || false
      end
    end

    def import_card_faces(card, faces_data)
      faces_data.each_with_index do |face_data, index|
        face = card.card_faces.find_or_initialize_by(face_index: index)

        face.assign_attributes(
          name: face_data["name"],
          mana_cost: face_data["mana_cost"],
          type_line: face_data["type_line"],
          oracle_text: face_data["oracle_text"],
          colors: face_data["colors"] || [],
          color_indicator: face_data["color_indicator"],
          power: face_data["power"],
          toughness: face_data["toughness"],
          loyalty: face_data["loyalty"],
          defense: face_data["defense"],
          flavor_text: face_data["flavor_text"],
          artist: face_data["artist"],
          artist_id: face_data["artist_id"],
          illustration_id: face_data["illustration_id"],
          image_uris: face_data["image_uris"] || {},
          flavor_name: face_data["flavor_name"],
          printed_name: face_data["printed_name"],
          printed_text: face_data["printed_text"],
          printed_type_line: face_data["printed_type_line"],
          watermark: face_data["watermark"],
          layout: face_data["layout"]
        )

        face.save!
      end
    end

    def import_legalities(card, legalities_data)
      legalities_data.each do |format, status|
        legality = card.card_legalities.find_or_initialize_by(format: format)
        legality.status = status
        legality.save!
      end
    end

    def import_related_cards(card, parts_data)
      parts_data.each do |part|
        next if part["id"] == card.id # Skip self-reference

        related = card.related_cards.find_or_initialize_by(
          related_card_id: part["id"],
          component: part["component"]
        )

        related.assign_attributes(
          name: part["name"],
          type_line: part["type_line"],
          uri: part["uri"]
        )

        related.save!
      end
    end
  end
end
