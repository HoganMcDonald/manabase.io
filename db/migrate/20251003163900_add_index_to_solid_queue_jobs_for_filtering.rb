# frozen_string_literal: true

class AddIndexToSolidQueueJobsForFiltering < ActiveRecord::Migration[8.0]
  def change
    # Add composite index for faster job filtering by class_name and finished_at
    # This speeds up queries in ScryfallSync#processing_jobs which filters by both
    add_index :solid_queue_jobs, [:class_name, :finished_at],
              name: "index_solid_queue_jobs_on_class_name_and_finished_at",
              if_not_exists: true
  end
end
