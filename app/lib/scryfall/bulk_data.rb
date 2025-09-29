# frozen_string_literal: true

module Scryfall
  class BulkData < Base
    self.element_name = "bulk-data"

    def self.find_by_type(type)
      find(type)
    rescue ActiveResource::ResourceNotFound
      nil
    end

    def self.oracle_cards
      find_by_type("oracle_cards")
    end

    def self.unique_artwork
      find_by_type("unique_artwork")
    end

    def self.default_cards
      find_by_type("default_cards")
    end

    def self.all_cards
      find_by_type("all_cards")
    end

    def self.rulings
      find_by_type("rulings")
    end

    def download_url
      download_uri
    end

    def file_size
      size
    end

    def size_in_mb
      return nil unless size
      (size.to_f / (1024 * 1024)).round(2)
    end
  end
end
