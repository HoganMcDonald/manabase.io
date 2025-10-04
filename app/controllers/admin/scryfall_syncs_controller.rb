# frozen_string_literal: true

class Admin::ScryfallSyncsController < InertiaController
  before_action :require_admin
  before_action :set_sync, only: [:show, :cancel, :retry]

  def index
    @syncs = ScryfallSync.order(created_at: :desc)

    render inertia: "admin/scryfall_syncs/index", props: {
      syncs: @syncs.map { |sync| serialize_sync(sync) }
    }
  end

  def show
    render json: {
      sync: serialize_sync_detailed(@sync)
    }
  end

  def progress
    syncs = if params[:ids].present?
      ScryfallSync.where(id: params[:ids])
    else
      ScryfallSync.processing
    end

    render json: {
      syncs: syncs.map { |sync|
        {
          id: sync.id,
          sync_type: sync.sync_type,
          status: sync.status,
          processing_status: sync.processing_status,
          job_progress: sync.job_progress,
          processing_progress: {
            total_records: sync.total_records,
            processed_records: sync.processed_records,
            percentage: sync.processing_progress_percentage,
            failed_batches: sync.failed_batches
          },
          estimated_completion: sync.estimated_completion_time
        }
      }
    }
  end

  def cancel
    if @sync.cancelable? && @sync.cancel!
      render json: {success: true, message: "Sync cancelled successfully"}
    else
      render json: {success: false, message: "Cannot cancel this sync"}, status: :unprocessable_entity
    end
  end

  def retry
    if @sync.failed?
      # Create a new sync record for the retry
      new_sync = ScryfallSync.create!(sync_type: @sync.sync_type, status: "pending")
      ScryfallSyncJob.perform_later(new_sync.id)
      render json: {success: true, message: "Sync retry queued"}
    else
      render json: {success: false, message: "Can only retry failed syncs"}, status: :unprocessable_entity
    end
  end

  def start
    sync_type = params[:sync_type]

    unless ScryfallSync::VALID_SYNC_TYPES.include?(sync_type)
      render json: {success: false, message: "Invalid sync type"}, status: :unprocessable_entity
      return
    end

    # Check if a sync is already in progress for this type
    if ScryfallSync.sync_in_progress?(sync_type)
      render json: {success: false, message: "Sync already in progress for #{sync_type}"}, status: :unprocessable_entity
      return
    end

    # Create a new sync record
    sync = ScryfallSync.create!(sync_type: sync_type, status: "pending")

    # Queue the sync job with the sync ID
    ScryfallSyncJob.perform_later(sync.id)
    render json: {success: true, message: "Sync queued for #{sync_type}"}
  rescue StandardError => e
    render json: {success: false, message: "Failed to start sync: #{e.message}"}, status: :unprocessable_entity
  end

  private

  def set_sync
    @sync = ScryfallSync.find(params[:id])
  end

  def serialize_sync(sync)
    {
      id: sync.id,
      sync_type: sync.sync_type,
      status: sync.status,
      version: sync.version,
      started_at: sync.started_at&.iso8601,
      completed_at: sync.completed_at&.iso8601,
      processing_status: sync.processing_status,
      total_records: sync.total_records,
      processed_records: sync.processed_records,
      failed_batches: sync.failed_batches,
      processing_progress_percentage: sync.processing_progress_percentage,
      created_at: sync.created_at.iso8601
    }
  end

  def serialize_sync_detailed(sync)
    serialize_sync(sync).merge(
      file_size: sync.file_size,
      error_message: sync.error_message,
      job_progress: sync.job_progress,
      failure_logs: sync.failure_logs || [],
      active_jobs_count: 0, # With Sidekiq, we track progress via processed_records instead
      processing_started_at: sync.processing_started_at&.iso8601,
      processing_completed_at: sync.processing_completed_at&.iso8601,
      estimated_completion_time: sync.estimated_completion_time
    )
  end
end
