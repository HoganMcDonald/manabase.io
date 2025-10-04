# frozen_string_literal: true

module Admin
  class SearchEvalsController < ApplicationController
    before_action :require_admin
    before_action :set_eval, only: [:show, :destroy]

    def index
      @evals = SearchEval.recent.limit(50)

      respond_to do |format|
        format.json do
          render json: {
            evals: @evals.as_json(methods: [:progress_percentage, :duration_formatted])
          }
        end
      end
    end

    def show
      respond_to do |format|
        format.json do
          render json: @eval.as_json(methods: [:progress_percentage, :duration_formatted])
        end
      end
    end

    def create
      # Check if there's already an eval in progress
      if SearchEval.in_progress.exists?
        return render json: {error: "An eval is already in progress"}, status: :unprocessable_entity
      end

      eval_type = params[:eval_type] || "keyword" # keyword, semantic, or hybrid
      use_llm_judge = params[:use_llm_judge] == "true"

      search_eval = SearchEval.create!(
        eval_type: eval_type,
        use_llm_judge: use_llm_judge
      )

      SearchEvalJob.perform_later(search_eval.id)

      render json: {
        message: "Search eval started",
        eval: search_eval.as_json(methods: [:progress_percentage, :duration_formatted])
      }, status: :created
    end

    def destroy
      if @eval.running?
        # Note: This just marks it as failed, doesn't actually stop the job
        @eval.update!(error_message: "Cancelled by user")
        @eval.fail!
        render json: {message: "Eval cancelled"}
      else
        render json: {error: "Can only cancel running evals"}, status: :unprocessable_entity
      end
    end

    def progress
      evals = SearchEval.in_progress

      render json: {
        evals: evals.as_json(methods: [:progress_percentage, :duration_formatted])
      }
    end

    private

    def set_eval
      @eval = SearchEval.find(params[:id])
    end
  end
end
