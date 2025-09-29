# frozen_string_literal: true

FactoryBot.define do
  factory :scryfall_sync do
    sync_type { "oracle_cards" }
    status { "pending" }
    batch_size { 500 }

    trait :with_version do
      version { "2025-01-01" }
      download_uri { "https://data.scryfall.io/oracle-cards/oracle-cards-20250101.json" }
    end

    trait :downloading do
      status { "downloading" }
      started_at { 1.hour.ago }
    end

    trait :completed do
      status { "completed" }
      started_at { 2.hours.ago }
      completed_at { 1.hour.ago }
      version { "2025-01-01" }
      file_path { Rails.root.join("spec", "fixtures", "files", "oracle_cards_sample.json").to_s }
      file_size { 1024000 }
      download_uri { "https://data.scryfall.io/oracle-cards/oracle-cards-20250101.json" }
    end

    trait :failed do
      status { "failed" }
      started_at { 2.hours.ago }
      completed_at { 1.hour.ago }
      error_message { "Download failed: Connection timeout" }
    end

    trait :cancelled do
      status { "cancelled" }
      started_at { 30.minutes.ago }
      cancelled_at { 10.minutes.ago }
    end

    trait :processing do
      status { "completed" }
      processing_status { "processing" }
      processing_started_at { 30.minutes.ago }
      total_records { 30000 }
      processed_records { 15000 }
      last_processed_batch { 30 }
    end

    trait :processing_queued do
      status { "completed" }
      processing_status { "queued" }
      version { "2025-01-01" }
      file_path { Rails.root.join("spec", "fixtures", "files", "oracle_cards_sample.json").to_s }
    end

    trait :processing_completed do
      status { "completed" }
      processing_status { "completed" }
      processing_started_at { 2.hours.ago }
      processing_completed_at { 1.hour.ago }
      total_records { 30000 }
      processed_records { 30000 }
      failed_batches { 0 }
      last_processed_batch { 60 }
    end

    trait :processing_failed do
      status { "completed" }
      processing_status { "failed" }
      processing_started_at { 2.hours.ago }
      processing_completed_at { 1.hour.ago }
      total_records { 30000 }
      processed_records { 10000 }
      failed_batches { 5 }
      error_message { "Processing error: JSON parsing failed" }
    end

    trait :unique_artwork do
      sync_type { "unique_artwork" }
    end

    trait :default_cards do
      sync_type { "default_cards" }
    end

    trait :all_cards do
      sync_type { "all_cards" }
    end

    trait :rulings do
      sync_type { "rulings" }
    end
  end
end
