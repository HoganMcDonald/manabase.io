# frozen_string_literal: true

class ScryfallSync < ApplicationRecord
  include AASM

  VALID_SYNC_TYPES = %w[oracle_cards unique_artwork default_cards all_cards rulings].freeze

  validates :sync_type, presence: true, inclusion: { in: VALID_SYNC_TYPES }
  validates :version, uniqueness: { scope: :sync_type }, allow_nil: true

  scope :by_type, ->(type) { where(sync_type: type) }
  scope :pending_or_downloading, -> { where(status: %w[pending downloading]) }

  # AASM state machine configuration
  aasm column: :status do
    state :pending, initial: true
    state :downloading
    state :completed
    state :failed
    state :cancelled

    event :start do
      transitions from: :pending, to: :downloading do
        after do
          self.started_at = Time.current
        end
      end
    end

    event :complete do
      transitions from: :downloading, to: :completed do
        after do |file_path, file_size|
          self.completed_at = Time.current
          self.file_path = file_path
          self.file_size = file_size
          self.error_message = nil
        end
      end
    end

    event :fail do
      transitions from: [:pending, :downloading], to: :failed do
        after do |error_message|
          self.completed_at = Time.current
          self.error_message = error_message
        end
      end
    end

    event :cancel do
      transitions from: [:pending, :downloading], to: :cancelled do
        guard do
          destroy_associated_jobs
        end
        after do
          self.cancelled_at = Time.current
        end
      end
    end
  end

  def self.latest_for_type(type)
    by_type(type).completed.order(created_at: :desc).first
  end

  def self.sync_in_progress?(type)
    by_type(type).pending_or_downloading.exists?
  end

  def cancelable?
    pending? || downloading?
  end

  def duration
    return nil unless started_at

    ending = completed_at || Time.current
    ending - started_at
  end

  def needs_update?(remote_version)
    return true if version.blank?

    version != remote_version
  end

  def storage_directory
    Rails.root.join("storage", "scryfall", sync_type)
  end

  def cleanup_old_files!
    return unless file_path.present? && File.exist?(file_path)

    File.delete(file_path)
    Rails.logger.info "Deleted old file: #{file_path}"
  rescue StandardError => e
    Rails.logger.error "Failed to delete old file #{file_path}: #{e.message}"
  end

  def associated_jobs
    SolidQueue::Job
      .where("(arguments::json->'arguments'->0)::text = ?", id.to_s)
  end

  def active_jobs
    associated_jobs.where(finished_at: nil)
  end

  private

  def destroy_associated_jobs
    job_count = active_jobs.count
    active_jobs.destroy_all
    Rails.logger.info "Cancelled #{job_count} associated jobs for sync #{id}"
    true
  rescue StandardError => e
    Rails.logger.error "Failed to destroy jobs for sync #{id}: #{e.message}"
    false
  end
end