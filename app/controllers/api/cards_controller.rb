# frozen_string_literal: true

module Api
  class CardsController < ApplicationController
    skip_before_action :authenticate, only: [:autocomplete, :search]

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

      # Limit per_page to reasonable values
      per_page = [[per_page, 1].max, 100].min

      filters = build_filters

      search_service = Search::CardSearch.new
      results = search_service.search(query, filters: filters, page: page, per_page: per_page)

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

      # Sort order
      filters[:sort] = params[:sort] if params[:sort].present?

      filters
    end
  end
end
