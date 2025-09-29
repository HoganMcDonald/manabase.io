# frozen_string_literal: true

module Scryfall
  class RulingMapper
    def import_ruling(data)
      # Rulings are linked by oracle_id
      ruling = CardRuling.find_or_initialize_by(
        oracle_id: data["oracle_id"],
        published_at: data["published_at"],
        comment: data["comment"]
      )

      ruling.source = data["source"]
      ruling.save!

      ruling
    end

    def import_rulings_batch(rulings_data)
      rulings_to_insert = []
      rulings_to_update = []

      rulings_data.each do |data|
        attributes = {
          oracle_id: data["oracle_id"],
          source: data["source"],
          published_at: data["published_at"],
          comment: data["comment"]
        }

        # Check if ruling exists
        existing = CardRuling.find_by(
          oracle_id: data["oracle_id"],
          published_at: data["published_at"],
          comment: data["comment"]
        )

        if existing
          rulings_to_update << existing.attributes.merge(attributes)
        else
          rulings_to_insert << attributes
        end
      end

      # Bulk insert new rulings
      CardRuling.insert_all(rulings_to_insert) if rulings_to_insert.any?

      # Bulk update existing rulings (if needed)
      if rulings_to_update.any?
        CardRuling.upsert_all(rulings_to_update)
      end

      rulings_to_insert.size + rulings_to_update.size
    end
  end
end
