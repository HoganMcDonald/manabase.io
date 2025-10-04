# frozen_string_literal: true

class SearchEval < ApplicationRecord
  include AASM

  # AASM State Machine
  aasm column: :status do
    state :pending, initial: true
    state :running
    state :completed
    state :failed

    event :start_running do
      transitions from: :pending, to: :running
      after do
        update!(started_at: Time.current)
      end
    end

    event :complete do
      transitions from: :running, to: :completed
      after do
        update!(completed_at: Time.current)
      end
    end

    event :fail do
      transitions from: [:pending, :running], to: :failed
      after do
        update!(completed_at: Time.current)
      end
    end

    event :retry_eval do
      transitions from: :failed, to: :pending
      after do
        update!(
          started_at: nil,
          completed_at: nil,
          error_message: nil,
          completed_queries: 0,
          failed_queries: 0,
          avg_precision: nil,
          avg_recall: nil,
          avg_mrr: nil,
          avg_ndcg: nil,
          results: nil
        )
      end
    end
  end

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :in_progress, -> { where(status: :running) }
  scope :completed_recently, -> { where(status: :completed).where("completed_at > ?", 1.day.ago) }

  # Calculate progress percentage
  def progress_percentage
    return 0 unless total_queries&.positive?
    ((completed_queries.to_f / total_queries) * 100).round(2)
  end

  # Check if eval is currently running
  def running?
    status == "running"
  end

  # Duration of the eval
  def duration
    return nil unless started_at
    end_time = completed_at || Time.current
    end_time - started_at
  end

  # Format duration as human readable string
  def duration_formatted
    return "N/A" unless duration
    seconds = duration.to_i
    if seconds < 60
      "#{seconds}s"
    elsif seconds < 3600
      "#{seconds / 60}m #{seconds % 60}s"
    else
      "#{seconds / 3600}h #{(seconds % 3600) / 60}m"
    end
  end

  # Update aggregate metrics
  def update_metrics!(metrics)
    update!(
      avg_precision: metrics[:avg_precision],
      avg_recall: metrics[:avg_recall],
      avg_mrr: metrics[:avg_mrr],
      avg_ndcg: metrics[:avg_ndcg]
    )
  end
end
