# frozen_string_literal: true

FactoryBot.define do
  factory :search_eval do
    status { "MyString" }
    eval_type { "MyString" }
    total_queries { 1 }
    completed_queries { 1 }
    failed_queries { 1 }
    avg_precision { "9.99" }
    avg_recall { "9.99" }
    avg_mrr { "9.99" }
    avg_ndcg { "9.99" }
    use_llm_judge { false }
    started_at { "2025-10-02 17:42:49" }
    completed_at { "2025-10-02 17:42:49" }
    error_message { "MyText" }
    results { "" }
  end
end
