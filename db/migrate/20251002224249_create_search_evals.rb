# frozen_string_literal: true

class CreateSearchEvals < ActiveRecord::Migration[8.0]
  def change
    create_table :search_evals do |t|
      t.string :status
      t.string :eval_type
      t.integer :total_queries
      t.integer :completed_queries
      t.integer :failed_queries
      t.decimal :avg_precision
      t.decimal :avg_recall
      t.decimal :avg_mrr
      t.decimal :avg_ndcg
      t.boolean :use_llm_judge
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message
      t.jsonb :results

      t.timestamps
    end
  end
end
