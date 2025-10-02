# frozen_string_literal: true

module Admin
  class OpenSearchSyncsController < ApplicationController
    before_action :require_admin
    before_action :set_sync, only: [:show, :destroy]

    def index
      @syncs = OpenSearchSync.recent.limit(50)
      @index_stats = Search::CardIndexer.new.index_stats

      respond_to do |format|
        format.json do
          render json: {
            syncs: @syncs.as_json(methods: [:progress_percentage, :duration_formatted]),
            index_stats: @index_stats
          }
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          render json: @sync.as_json(methods: [:progress_percentage, :duration_formatted])
        end
      end
    end

    def create
      # Check if there's already a sync in progress
      if OpenSearchSync.in_progress.exists?
        return render json: {error: "A sync is already in progress"}, status: :unprocessable_entity
      end

      sync = OpenSearchSync.create!
      OpenSearchReindexJob.perform_later(sync.id)

      render json: {
        message: "Reindex started",
        sync: sync.as_json(methods: [:progress_percentage, :duration_formatted])
      }, status: :created
    end

    def destroy
      if @sync.running?
        # Note: This just marks it as failed, doesn't actually stop the job
        @sync.update!(error_message: "Cancelled by user")
        @sync.fail!
        render json: {message: "Sync cancelled"}
      else
        render json: {error: "Can only cancel running syncs"}, status: :unprocessable_entity
      end
    end

    def progress
      syncs = OpenSearchSync.in_progress
      index_stats = Search::CardIndexer.new.index_stats

      render json: {
        syncs: syncs.as_json(methods: [:progress_percentage, :duration_formatted]),
        index_stats: index_stats
      }
    end

    private

    def set_sync
      @sync = OpenSearchSync.find(params[:id])
    end
  end
end
