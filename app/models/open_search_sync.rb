# frozen_string_literal: true

class OpenSearchSync < ApplicationRecord
  include AASM

  # AASM State Machine
  aasm column: :status do
    state :pending, initial: true
    state :indexing
    state :completed
    state :failed

    event :start_indexing do
      transitions from: :pending, to: :indexing
      after do
        update!(started_at: Time.current)
      end
    end

    event :complete do
      transitions from: :indexing, to: :completed
      after do
        update!(completed_at: Time.current)
      end
    end

    event :fail do
      transitions from: [:pending, :indexing], to: :failed
      after do
        update!(completed_at: Time.current)
      end
    end

    event :retry_sync do
      transitions from: :failed, to: :pending
      after do
        update!(
          started_at: nil,
          completed_at: nil,
          error_message: nil,
          indexed_cards: 0,
          failed_cards: 0
        )
      end
    end
  end

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :in_progress, -> { where(status: :indexing) }
  scope :completed_recently, -> { where(status: :completed).where("completed_at > ?", 1.day.ago) }

  # Calculate progress percentage
  def progress_percentage
    return 0 if total_cards.zero?
    ((indexed_cards.to_f / total_cards) * 100).round(2)
  end

  # Check if sync is currently running
  def running?
    indexing?
  end

  # Duration of the sync
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
end
