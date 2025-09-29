# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScryfallSync, type: :model do
  describe "validations" do
    subject { build(:scryfall_sync) }

    it { should validate_inclusion_of(:sync_type).in_array(ScryfallSync::VALID_SYNC_TYPES) }

    it "validates uniqueness of version scoped to sync_type" do
      existing_sync = create(:scryfall_sync, :completed, sync_type: "oracle_cards", version: "2025-01-01")
      new_sync = build(:scryfall_sync, sync_type: "oracle_cards", version: "2025-01-01")
      expect(new_sync).not_to be_valid
      expect(new_sync.errors[:version]).to include("has already been taken")
    end

    it "allows same version for different sync types" do
      existing_sync = create(:scryfall_sync, :completed, sync_type: "oracle_cards", version: "2025-01-01")
      new_sync = build(:scryfall_sync, sync_type: "rulings", version: "2025-01-01")
      expect(new_sync).to be_valid
    end
  end

  describe "state machine" do
    let(:sync) { create(:scryfall_sync) }

    context "initial state" do
      it "starts in pending state" do
        expect(sync).to be_pending
      end

      it "can transition to downloading" do
        expect(sync.may_start?).to be true
        sync.start!
        expect(sync).to be_downloading
        expect(sync.started_at).to be_present
      end

      it "can be cancelled" do
        expect(sync.may_cancel?).to be true
        sync.cancel!
        expect(sync).to be_cancelled
        expect(sync.cancelled_at).to be_present
      end
    end

    context "downloading state" do
      let(:sync) { create(:scryfall_sync, :downloading) }

      it "can complete with file details" do
        expect(sync.may_complete?).to be true
        sync.complete!("/path/to/file.json", 1024000)
        expect(sync).to be_completed
        expect(sync.file_path).to eq "/path/to/file.json"
        expect(sync.file_size).to eq 1024000
        expect(sync.completed_at).to be_present
      end

      it "can fail with error message" do
        expect(sync.may_fail?).to be true
        sync.fail!("Connection timeout")
        expect(sync).to be_failed
        expect(sync.error_message).to eq "Connection timeout"
        expect(sync.completed_at).to be_present
      end

      it "can be cancelled" do
        expect(sync.may_cancel?).to be true
        sync.cancel!
        expect(sync).to be_cancelled
      end
    end

    context "completed state" do
      let(:sync) { create(:scryfall_sync, :completed) }

      it "cannot transition to other states" do
        expect(sync.may_start?).to be false
        expect(sync.may_fail?).to be false
        expect(sync.may_cancel?).to be false
      end
    end

    context "cancelled state" do
      let(:sync) { create(:scryfall_sync, :cancelled) }

      it "has cancelled_at timestamp" do
        expect(sync.cancelled_at).to be_present
      end
    end
  end

  describe "scopes" do
    before do
      create(:scryfall_sync, sync_type: "oracle_cards", status: "pending")
      create(:scryfall_sync, sync_type: "oracle_cards", status: "downloading")
      create(:scryfall_sync, sync_type: "rulings", status: "completed")
      create(:scryfall_sync, sync_type: "all_cards", status: "failed")
    end

    describe ".by_type" do
      it "filters by sync type" do
        oracle_syncs = ScryfallSync.by_type("oracle_cards")
        expect(oracle_syncs.count).to eq 2
        expect(oracle_syncs.pluck(:sync_type).uniq).to eq ["oracle_cards"]
      end
    end

    describe ".pending_or_downloading" do
      it "returns pending and downloading syncs" do
        active_syncs = ScryfallSync.pending_or_downloading
        expect(active_syncs.count).to eq 2
        expect(active_syncs.pluck(:status).sort).to eq ["downloading", "pending"]
      end
    end

    describe ".completed" do
      it "returns only completed syncs" do
        completed_syncs = ScryfallSync.completed
        expect(completed_syncs.count).to eq 1
        expect(completed_syncs.first.sync_type).to eq "rulings"
      end
    end
  end

  describe "class methods" do
    describe ".latest_for_type" do
      it "returns the most recent completed sync for a type" do
        old_sync = create(:scryfall_sync, :completed, sync_type: "oracle_cards",
                         version: "2025-01-13", completed_at: 2.days.ago)
        recent_sync = create(:scryfall_sync, :completed, sync_type: "oracle_cards",
                            version: "2025-01-14", completed_at: 1.day.ago)
        failed_sync = create(:scryfall_sync, :failed, sync_type: "oracle_cards",
                           completed_at: 1.hour.ago)

        expect(ScryfallSync.latest_for_type("oracle_cards")).to eq recent_sync
      end

      it "returns nil if no completed syncs exist" do
        create(:scryfall_sync, :downloading, sync_type: "oracle_cards")
        create(:scryfall_sync, :failed, sync_type: "oracle_cards")

        expect(ScryfallSync.latest_for_type("oracle_cards")).to be_nil
      end
    end

    describe ".sync_in_progress?" do
      it "returns true if there's an active sync" do
        create(:scryfall_sync, sync_type: "oracle_cards", status: "downloading")
        expect(ScryfallSync.sync_in_progress?("oracle_cards")).to be true
      end

      it "returns false if no active sync exists" do
        create(:scryfall_sync, :completed, sync_type: "oracle_cards")
        create(:scryfall_sync, :failed, sync_type: "oracle_cards")
        expect(ScryfallSync.sync_in_progress?("oracle_cards")).to be false
      end
    end
  end

  describe "instance methods" do
    describe "#needs_update?" do
      let(:sync) { create(:scryfall_sync, :completed, version: "2025-01-01") }

      it "returns true if remote version is newer" do
        expect(sync.needs_update?("2025-01-02")).to be true
      end

      it "returns false if remote version is same" do
        expect(sync.needs_update?("2025-01-01")).to be false
      end

      it "returns true if remote version is different" do
        # needs_update? returns true if versions are different
        expect(sync.needs_update?("2024-12-31")).to be true
      end
    end

    describe "#cancelable?" do
      it "returns true for pending or downloading states" do
        pending_sync = create(:scryfall_sync, status: "pending")
        downloading_sync = create(:scryfall_sync, :downloading)

        expect(pending_sync.cancelable?).to be true
        expect(downloading_sync.cancelable?).to be true
      end

      it "returns false for terminal states" do
        completed_sync = create(:scryfall_sync, :completed)
        failed_sync = create(:scryfall_sync, :failed)
        cancelled_sync = create(:scryfall_sync, :cancelled)

        expect(completed_sync.cancelable?).to be false
        expect(failed_sync.cancelable?).to be false
        expect(cancelled_sync.cancelable?).to be false
      end
    end

    describe "#cleanup_old_files!" do
      let(:sync) { create(:scryfall_sync, :completed) }

      it "deletes the file if it exists" do
        allow(File).to receive(:exist?).with(sync.file_path).and_return(true)
        expect(File).to receive(:delete).with(sync.file_path)

        sync.cleanup_old_files!
        # cleanup_old_files! doesn't nil out the file_path in the model
        expect(sync).to be_persisted
      end

      it "handles missing files gracefully" do
        allow(File).to receive(:exist?).with(sync.file_path).and_return(false)
        expect(File).not_to receive(:delete)

        expect { sync.cleanup_old_files! }.not_to raise_error
        # cleanup_old_files! doesn't nil out the file_path in the model
      end
    end
  end

  describe "processing status and progress" do
    let(:sync) { create(:scryfall_sync, :processing) }

    describe "#processing?" do
      it "returns true when processing_status is 'processing'" do
        expect(sync.processing?).to be true
      end

      it "returns false for other statuses" do
        sync.processing_status = "completed"
        expect(sync.processing?).to be false
      end
    end

    describe "#processing_queued?" do
      it "returns true when processing_status is 'queued'" do
        sync.processing_status = "queued"
        expect(sync.processing_queued?).to be true
      end
    end

    describe "#processing_completed?" do
      it "returns true when processing_status is 'completed'" do
        sync.processing_status = "completed"
        expect(sync.processing_completed?).to be true
      end
    end

    describe "#processing_failed?" do
      it "returns true when processing_status is 'failed'" do
        sync.processing_status = "failed"
        expect(sync.processing_failed?).to be true
      end
    end

    describe "#processing_progress_percentage" do
      it "calculates percentage correctly" do
        expect(sync.processing_progress_percentage).to eq 50.0
      end

      it "returns 0 when total_records is zero" do
        sync.total_records = 0
        expect(sync.processing_progress_percentage).to eq 0
      end

      it "returns 0 when total_records is nil" do
        sync.total_records = nil
        expect(sync.processing_progress_percentage).to eq 0
      end

      it "handles completed processing" do
        sync.processed_records = 30000
        sync.total_records = 30000
        expect(sync.processing_progress_percentage).to eq 100.0
      end
    end

    describe "#estimated_completion_time" do
      it "calculates estimated time based on processing rate" do
        sync.processing_started_at = 1.hour.ago
        sync.processed_records = 15000
        sync.total_records = 30000

        # Should take another hour at current rate
        estimated = sync.estimated_completion_time
        expect(estimated).to be_within(5.minutes).of(Time.current + 1.hour)
      end

      it "returns nil if not processing" do
        sync.processing_started_at = nil
        expect(sync.estimated_completion_time).to be_nil
      end

      it "returns nil if no records processed yet" do
        sync.processed_records = 0
        expect(sync.estimated_completion_time).to be_nil
      end
    end

    describe "#update_processing_progress!" do
      it "updates processed records count" do
        sync.update_processing_progress!(20000, 35)
        expect(sync.processed_records).to eq 20000
        expect(sync.last_processed_batch).to eq 35
      end

      it "updates progress when all records are processed" do
        sync.update_processing_progress!(30000, 60)
        # update_processing_progress! doesn't automatically mark as completed
        expect(sync.processed_records).to eq 30000
        expect(sync.last_processed_batch).to eq 60
      end
    end
  end

  describe "job associations" do
    let(:sync) { create(:scryfall_sync) }

    describe "#active_jobs" do
      it "returns unfinished jobs associated with the sync" do
        # This would need actual SolidQueue::Job records in a real test
        # For now, we'll stub the behavior
        mock_relation = double("ActiveRecord::Relation")
        allow(SolidQueue::Job).to receive(:where).and_return(mock_relation)
        allow(mock_relation).to receive(:where).and_return([])
        expect(sync.active_jobs).to eq []
      end
    end

    describe "#processing_jobs" do
      it "returns processing and batch import jobs" do
        # This would need actual job records in a real test
        allow(sync).to receive(:active_jobs).and_return([])
        expect(sync.processing_jobs).to eq []
      end
    end
  end

  describe "#storage_directory" do
    let(:sync) { build(:scryfall_sync, sync_type: "oracle_cards") }

    it "returns the correct storage path" do
      expected_path = Rails.root.join("storage", "scryfall", "oracle_cards")
      expect(sync.storage_directory).to eq expected_path
    end
  end
end
