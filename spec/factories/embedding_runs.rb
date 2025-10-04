# frozen_string_literal: true

FactoryBot.define do
  factory :embedding_run do
    status { "MyString" }
    total_cards { 1 }
    processed_cards { 1 }
    failed_cards { 1 }
    batch_size { 1 }
    started_at { "2025-10-02 17:42:58" }
    completed_at { "2025-10-02 17:42:58" }
    error_message { "MyText" }
  end
end
