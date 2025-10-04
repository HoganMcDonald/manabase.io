# frozen_string_literal: true

class ClearSidekiqJobsJob < ApplicationJob
  queue_as :default

  def perform
    # Sidekiq automatically manages job retention via the dead job queue
    # This job exists to maintain parity with the old Solid Queue cleanup job
    # The Sidekiq dead job queue has a max size (default 10,000) and max retention (default 6 months)
    # so no manual cleanup is needed, but we keep this job as a placeholder
    # for any future cleanup tasks

    # If you need custom cleanup, you can access Sidekiq stats:
    # stats = Sidekiq::Stats.new
    # Rails.logger.info "Sidekiq Stats - Processed: #{stats.processed}, Failed: #{stats.failed}"
  end
end
