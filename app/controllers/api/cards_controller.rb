# frozen_string_literal: true

module Api
  class CardsController < ApplicationController
    skip_before_action :authenticate, only: [:autocomplete, :search, :keywords, :types]

    def types
      # Get all unique card types from type_line, split by spaces and dashes
      # This extracts individual types like "Creature", "Legendary", "Goblin", etc.
      types = Card.connection.select_values(
        <<-SQL
          SELECT DISTINCT unnest(
            string_to_array(
              regexp_replace(type_line, '[—–-]', ' ', 'g'),
              ' '
            )
          ) as card_type
          FROM cards
          WHERE type_line IS NOT NULL
          ORDER BY card_type
        SQL
      ).reject(&:blank?)

      render json: types
    rescue StandardError => e
      Rails.logger.error("Types fetch error: #{e.message}")
      render json: {error: "Failed to fetch types"}, status: :internal_server_error
    end

    def keywords
      # Get all unique keywords from cards, sorted alphabetically
      # keywords is stored as JSONB, so we use jsonb_array_elements_text
      keywords = Card.connection.select_values(
        "SELECT DISTINCT jsonb_array_elements_text(keywords) as keyword FROM cards WHERE keywords IS NOT NULL AND jsonb_array_length(keywords) > 0 ORDER BY keyword"
      )

      render json: keywords
    rescue StandardError => e
      Rails.logger.error("Keywords fetch error: #{e.message}")
      render json: {error: "Failed to fetch keywords"}, status: :internal_server_error
    end

    def autocomplete
      query = params[:q]

      if query.blank?
        return render json: []
      end

      search_service = Search::CardSearch.new
      results = search_service.autocomplete(query, limit: params[:limit]&.to_i || 10)

      render json: results
    rescue StandardError => e
      Rails.logger.error("Autocomplete error: #{e.message}")
      render json: {error: "Search failed"}, status: :internal_server_error
    end

    def search
      query = params[:q]
      page = params[:page]&.to_i || 1
      per_page = params[:per_page]&.to_i || 20
      search_mode = params[:search_mode] || "auto"

      # Limit per_page to reasonable values
      per_page = [[per_page, 1].max, 100].min

      # Validate search_mode
      valid_modes = %w[auto keyword semantic hybrid]
      search_mode = "auto" unless valid_modes.include?(search_mode)

      filters = build_filters

      search_service = Search::CardSearch.new
      results = search_service.search(query, filters: filters, page: page, per_page: per_page, search_mode: search_mode)

      render json: results
    rescue StandardError => e
      Rails.logger.error("Search error: #{e.message}")
      render json: {
        error: "Search failed",
        results: [],
        total: 0,
        page: page,
        per_page: per_page,
        total_pages: 0
      }, status: :internal_server_error
    end

    private

    def build_filters
      filters = {}

      # Color identity filter
      if params[:colors].present?
        filters[:colors] = Array(params[:colors])
        filters[:color_match] = params[:color_match] if params[:color_match].present?
      end

      # CMC filters
      filters[:cmc_min] = params[:cmc_min] if params[:cmc_min].present?
      filters[:cmc_max] = params[:cmc_max] if params[:cmc_max].present?

      # Type filter
      filters[:types] = Array(params[:types]) if params[:types].present?

      # Format legality filter
      filters[:formats] = Array(params[:formats]) if params[:formats].present?

      # Keywords filter
      filters[:keywords] = Array(params[:keywords]) if params[:keywords].present?

      # Layout filter
      filters[:layout] = params[:layout] if params[:layout].present?

      # Reserved list filter
      filters[:reserved] = params[:reserved] if params[:reserved].present?

      # Rarity filter
      filters[:rarities] = Array(params[:rarities]) if params[:rarities].present?

      # Power/Toughness filters
      filters[:power_min] = params[:power_min] if params[:power_min].present?
      filters[:power_max] = params[:power_max] if params[:power_max].present?
      filters[:toughness_min] = params[:toughness_min] if params[:toughness_min].present?
      filters[:toughness_max] = params[:toughness_max] if params[:toughness_max].present?

      # Sort order
      filters[:sort] = params[:sort] if params[:sort].present?

      filters
    end
  end
end
