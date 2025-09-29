# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScryfallProcessingJob, type: :job do
  include ActiveJob::TestHelper

  let(:sync) do
    create(:scryfall_sync, :completed,
          sync_type: "oracle_cards",
          file_path: Rails.root.join("spec/fixtures/files/oracle_cards_sample.json").to_s,
          batch_size: 2)
  end

  describe "#perform" do
    context "with valid sync and file" do
      it "updates sync to processing status" do
        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.processing_status).to eq "completed"
        expect(sync.processing_started_at).to be_present
        expect(sync.processing_completed_at).to be_present
      end

      it "counts total records correctly" do
        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.total_records).to eq 5 # 5 records in oracle_cards_sample.json
      end

      it "creates batch import jobs" do
        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.to have_enqueued_job(ScryfallBatchImportJob).exactly(3).times
        # 5 records with batch_size 2 = 3 batches (2, 2, 1)
      end

      it "passes correct batch data to import jobs" do
        batch_data = []

        allow(ScryfallBatchImportJob).to receive(:perform_later) do |args|
          batch_data << args
        end

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        expect(batch_data.size).to eq 3
        expect(batch_data[0][:batch_number]).to eq 1
        expect(batch_data[0][:records].size).to eq 2
        expect(batch_data[1][:batch_number]).to eq 2
        expect(batch_data[1][:records].size).to eq 2
        expect(batch_data[2][:batch_number]).to eq 3
        expect(batch_data[2][:records].size).to eq 1
      end

      it "updates processed records count" do
        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.processed_records).to eq 5
        expect(sync.last_processed_batch).to eq 3
      end
    end

    context "with rulings sync type" do
      let(:sync) do
        create(:scryfall_sync, :completed,
              sync_type: "rulings",
              file_path: Rails.root.join("spec/fixtures/files/rulings_sample.json").to_s,
              batch_size: 2)
      end

      it "processes rulings correctly" do
        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.to have_enqueued_job(ScryfallBatchImportJob)
          .with(hash_including(sync_type: "rulings"))
      end
    end

    context "with default_cards sync type" do
      let(:sync) do
        create(:scryfall_sync, :completed,
              sync_type: "default_cards",
              file_path: Rails.root.join("spec/fixtures/files/default_cards_sample.json").to_s,
              batch_size: 1)
      end

      it "processes card printings correctly" do
        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.to have_enqueued_job(ScryfallBatchImportJob)
          .with(hash_including(sync_type: "default_cards"))
      end
    end

    context "when sync is not completed" do
      let(:sync) { create(:scryfall_sync, :downloading) }

      it "does not process non-completed syncs" do
        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.not_to have_enqueued_job(ScryfallBatchImportJob)
      end
    end

    context "when file does not exist" do
      let(:sync) do
        create(:scryfall_sync, :completed,
              file_path: "/non/existent/file.json")
      end

      it "marks sync as failed with error message" do
        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.processing_status).to eq "failed"
        expect(sync.error_message).to include "File not found"
      end
    end

    context "with empty file" do
      let(:sync) do
        create(:scryfall_sync, :completed,
              file_path: Rails.root.join("spec/fixtures/files/empty.json").to_s)
      end

      it "handles empty files gracefully" do
        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.total_records).to eq 0
        expect(sync.processed_records).to eq 0
        expect(sync.processing_status).to eq "completed"
      end

      it "does not create any batch jobs" do
        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.not_to have_enqueued_job(ScryfallBatchImportJob)
      end
    end

    context "with malformed JSON" do
      let(:sync) do
        create(:scryfall_sync, :completed,
              file_path: Rails.root.join("spec/fixtures/files/malformed.json").to_s)
      end

      it "skips invalid JSON lines and continues processing" do
        allow(Rails.logger).to receive(:warn)

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.total_records).to eq 0 # Both lines are malformed
        expect(sync.processing_status).to eq "completed"
        expect(Rails.logger).to have_received(:warn).at_least(:once)
      end
    end

    context "with large batch size" do
      let(:sync) do
        create(:scryfall_sync, :completed,
              file_path: Rails.root.join("spec/fixtures/files/oracle_cards_sample.json").to_s,
              batch_size: 1000)
      end

      it "creates single batch for all records" do
        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.to have_enqueued_job(ScryfallBatchImportJob).once
      end
    end

    context "progress tracking" do
      it "updates progress after each batch" do
        progress_updates = []

        allow(sync).to receive(:update_processing_progress!) do |processed, batch|
          progress_updates << {processed: processed, batch: batch}
        end.and_call_original

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        expect(progress_updates).to eq [
          {processed: 2, batch: 1},
          {processed: 4, batch: 2},
          {processed: 5, batch: 3}
        ]
      end

      it "marks as completed when all records are processed" do
        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.processing_status).to eq "completed"
        expect(sync.processing_completed_at).to be_present
      end
    end

    context "error handling" do
      it "logs errors and marks sync as failed" do
        allow(File).to receive(:open).and_raise(StandardError, "File read error")
        allow(Rails.logger).to receive(:error)

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.processing_status).to eq "failed"
        expect(sync.error_message).to include "File read error"
        expect(Rails.logger).to have_received(:error).at_least(:once)
      end

      it "does not create batch jobs when counting fails" do
        allow(File).to receive(:foreach).and_raise(StandardError, "Read error")

        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.not_to have_enqueued_job(ScryfallBatchImportJob)
      end
    end

    context "performance" do
      it "processes file in streaming manner" do
        # Verify that we're not loading entire file into memory
        expect(File).not_to receive(:read)
        expect(File).to receive(:foreach).at_least(:once).and_call_original

        perform_enqueued_jobs { described_class.perform_later(sync.id) }
      end
    end
  end

  describe "private methods" do
    subject { described_class.new }

    describe "#count_records" do
      it "counts valid JSON lines" do
        file_path = Rails.root.join("spec/fixtures/files/oracle_cards_sample.json")
        count = subject.send(:count_records, file_path)
        expect(count).to eq 5
      end

      it "skips invalid JSON lines" do
        file_path = Rails.root.join("spec/fixtures/files/malformed.json")
        count = subject.send(:count_records, file_path)
        expect(count).to eq 0
      end
    end

    describe "#process_file_in_batches" do
      it "yields batches of specified size" do
        file_path = Rails.root.join("spec/fixtures/files/oracle_cards_sample.json")
        batches = []

        subject.send(:process_file_in_batches, sync, file_path) do |batch_number, records|
          batches << {number: batch_number, size: records.size}
        end

        expect(batches).to eq [
          {number: 1, size: 2},
          {number: 2, size: 2},
          {number: 3, size: 1}
        ]
      end
    end
  end
end
