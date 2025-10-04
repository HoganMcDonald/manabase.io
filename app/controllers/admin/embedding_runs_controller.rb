# frozen_string_literal: true

module Admin
  class EmbeddingRunsController < ApplicationController
    before_action :require_admin
    before_action :set_run, only: [:show, :destroy]

    def index
      @runs = EmbeddingRun.recent.limit(50)

      respond_to do |format|
        format.json do
          render json: {
            runs: @runs.as_json(methods: [:progress_percentage, :duration_formatted])
          }
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          render json: @run.as_json(methods: [:progress_percentage, :duration_formatted])
        end
      end
    end

    def create
      # Check if there's already a run in progress
      if EmbeddingRun.in_progress.exists?
        return render json: {error: "An embedding run is already in progress"}, status: :unprocessable_entity
      end

      start_id = params[:start_id]
      limit = params[:limit]
      batch_size = params[:batch_size] || 50

      embedding_run = EmbeddingRun.create!(
        batch_size: batch_size
      )

      EmbeddingBackfillJob.perform_later(embedding_run.id, start_id: start_id, limit: limit)

      render json: {
        message: "Embedding generation started",
        run: embedding_run.as_json(methods: [:progress_percentage, :duration_formatted])
      }, status: :created
    end

    def destroy
      if @run.running?
        # Note: This just marks it as failed, doesn't actually stop the job
        @run.update!(error_message: "Cancelled by user")
        @run.fail!
        render json: {message: "Embedding run cancelled"}
      else
        render json: {error: "Can only cancel running embedding runs"}, status: :unprocessable_entity
      end
    end

    def progress
      runs = EmbeddingRun.in_progress

      render json: {
        runs: runs.as_json(methods: [:progress_percentage, :duration_formatted])
      }
    end

    private

    def set_run
      @run = EmbeddingRun.find(params[:id])
    end
  end
end
