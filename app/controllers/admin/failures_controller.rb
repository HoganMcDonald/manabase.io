# frozen_string_literal: true

class Admin::FailuresController < InertiaController
  before_action :require_admin

  def index
    @syncs_with_failures = ScryfallSync
      .where.not(failure_logs: nil)
      .where.not(failure_logs: [])
      .order(updated_at: :desc)

    # Aggregate all failures
    all_failures = []
    @syncs_with_failures.each do |sync|
      sync.failure_logs.each_with_index do |log, index|
        all_failures << {
          id: "#{sync.id}-#{index}",
          sync_id: sync.id,
          sync_type: sync.sync_type,
          timestamp: log["timestamp"],
          error: log["error"],
          batch_number: log["batch_number"],
          context: log["context"],
          sync_version: sync.version
        }
      end
    end

    # Sort by timestamp (most recent first)
    all_failures.sort_by! { |f| f[:timestamp] }.reverse!

    # Group failures by error type
    error_groups = all_failures.group_by { |f| f[:context]&.dig("error_class") || "Unknown" }
    error_summary = error_groups.map { |error_class, failures|
      {
        error_class: error_class,
        count: failures.size,
        recent_example: failures.first,
        affected_syncs: failures.map { |f| f[:sync_type] }.uniq
      }
    }.sort_by { |g| -g[:count] }

    render inertia: "admin/failures/index", props: {
      failures: all_failures.first(100), # Limit to most recent 100
      total_failures: all_failures.size,
      error_summary: error_summary,
      syncs_with_failures: @syncs_with_failures.map { |sync|
        {
          id: sync.id,
          sync_type: sync.sync_type,
          failure_count: sync.failure_logs.size,
          last_updated: sync.updated_at.iso8601
        }
      }
    }
  end

  def clear
    sync = ScryfallSync.find(params[:sync_id])
    sync.clear_failure_logs

    redirect_to admin_failures_path, notice: "Cleared failure logs for #{sync.sync_type}"
  end
end
