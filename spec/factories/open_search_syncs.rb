# frozen_string_literal: true

FactoryBot.define do
  factory :open_search_sync do
    status { "MyString" }
    total_cards { 1 }
    indexed_cards { 1 }
    failed_cards { 1 }
    started_at { "2025-10-01 15:03:54" }
    completed_at { "2025-10-01 15:03:54" }
    error_message { "MyText" }
  end
end
