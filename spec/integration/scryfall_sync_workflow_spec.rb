# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe "Scryfall Sync Workflow", type: :integration do
  include ActiveJob::TestHelper

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after do
    WebMock.reset!
    clear_enqueued_jobs
  end

  describe "complete oracle_cards sync workflow" do
    let(:sync) { create(:scryfall_sync, sync_type: "oracle_cards", batch_size: 2) }

    before do
      # Mock Scryfall bulk data API
      bulk_data = double("BulkData",
                        updated_at: "2025-01-15",
                        download_uri: "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json",
                        size: 1000)
      allow(Scryfall::BulkData).to receive(:find_by_type).with("oracle_cards").and_return(bulk_data)

      # Mock file download
      stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
        .to_return(
          status: 200,
          body: File.read(Rails.root.join("spec/fixtures/files/oracle_cards_sample.json")),
          headers: {"Content-Length" => "1000"}
        )

      # Mock card mapper
      @card_mapper = instance_double(Scryfall::CardMapper)
      allow(Scryfall::CardMapper).to receive(:new).and_return(@card_mapper)
      allow(@card_mapper).to receive(:import_oracle_card)
    end

    it "completes full sync workflow from download to import" do
      # Start the sync job
      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      sync.reload

      # Verify download phase
      expect(sync).to be_completed
      expect(sync.version).to eq "2025-01-15"
      expect(sync.file_path).to be_present
      expect(sync.file_size).to eq 1000

      # Verify processing phase
      expect(sync.processing_status).to eq "completed"
      expect(sync.total_records).to eq 5
      expect(sync.processed_records).to eq 5
      expect(sync.last_processed_batch).to eq 3

      # Verify import calls
      expect(@card_mapper).to have_received(:import_oracle_card).exactly(5).times
    end

    it "handles sync cancellation during download" do
      # Setup cancellation during download
      allow_any_instance_of(Net::HTTP).to receive(:request) do |http, request|
        sync.reload.cancel!
        raise "Download cancelled"
      end

      expect {
        perform_enqueued_jobs do
          ScryfallSyncJob.perform_later(sync.id)
        end
      }.to raise_error("Download cancelled")

      sync.reload
      expect(sync).to be_cancelled
      expect(sync.file_path).to be_nil
    end

    it "recovers from individual record import failures" do
      # Make one import fail
      call_count = 0
      allow(@card_mapper).to receive(:import_oracle_card) do |record|
        call_count += 1
        raise StandardError, "Import failed" if call_count == 2
      end

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      sync.reload
      expect(sync.processing_status).to eq "completed"
      expect(@card_mapper).to have_received(:import_oracle_card).exactly(5).times
    end

    it "tracks progress accurately throughout workflow" do
      progress_snapshots = []

      # Capture progress at various points
      allow(sync).to receive(:update_processing_progress!).and_wrap_original do |method, *args|
        result = method.call(*args)
        progress_snapshots << {
          processed: sync.processed_records,
          total: sync.total_records,
          percentage: sync.processing_progress_percentage
        }
        result
      end

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      # Verify progress was tracked correctly
      expect(progress_snapshots).to eq [
        {processed: 2, total: 5, percentage: 40.0},
        {processed: 4, total: 5, percentage: 80.0},
        {processed: 5, total: 5, percentage: 100.0}
      ]
    end
  end

  describe "rulings sync workflow" do
    let(:sync) { create(:scryfall_sync, sync_type: "rulings", batch_size: 3) }

    before do
      # Mock Scryfall bulk data API
      bulk_data = double("BulkData",
                        updated_at: "2025-01-16",
                        download_uri: "https://data.scryfall.io/rulings/rulings-20250116.json",
                        size: 500)
      allow(Scryfall::BulkData).to receive(:find_by_type).with("rulings").and_return(bulk_data)

      # Mock file download
      stub_request(:get, "https://data.scryfall.io/rulings/rulings-20250116.json")
        .to_return(
          status: 200,
          body: File.read(Rails.root.join("spec/fixtures/files/rulings_sample.json")),
          headers: {"Content-Length" => "500"}
        )

      # Mock ruling mapper
      @ruling_mapper = instance_double(Scryfall::RulingMapper)
      allow(Scryfall::RulingMapper).to receive(:new).and_return(@ruling_mapper)
      allow(@ruling_mapper).to receive(:import_ruling)
    end

    it "imports rulings correctly" do
      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      sync.reload
      expect(sync).to be_completed
      expect(sync.processing_status).to eq "completed"
      expect(sync.total_records).to eq 5
      expect(@ruling_mapper).to have_received(:import_ruling).exactly(5).times
    end
  end

  describe "concurrent sync prevention" do
    it "prevents multiple syncs of same type" do
      sync1 = create(:scryfall_sync, sync_type: "oracle_cards", status: "downloading")
      sync2 = create(:scryfall_sync, sync_type: "oracle_cards", status: "pending")

      expect(ScryfallSync.sync_in_progress?("oracle_cards")).to be true

      # Second sync should not start
      allow_any_instance_of(ScryfallSync).to receive(:may_start?).and_return(false)

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync2.id)
      end

      sync2.reload
      expect(sync2).to be_pending # Should remain pending
    end

    it "allows syncs of different types to run concurrently" do
      sync1 = create(:scryfall_sync, sync_type: "oracle_cards", status: "downloading")
      sync2 = create(:scryfall_sync, sync_type: "rulings", status: "pending")

      expect(ScryfallSync.sync_in_progress?("oracle_cards")).to be true
      expect(ScryfallSync.sync_in_progress?("rulings")).to be false
    end
  end

  describe "version management" do
    it "skips download when already have latest version" do
      # Create existing sync with current version
      existing_sync = create(:scryfall_sync, :completed,
                           sync_type: "oracle_cards",
                           version: "2025-01-15")

      # Try new sync with same version
      new_sync = create(:scryfall_sync, sync_type: "oracle_cards")

      bulk_data = double("BulkData",
                        updated_at: "2025-01-15", # Same version
                        download_uri: "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json",
                        size: 1000)
      allow(Scryfall::BulkData).to receive(:find_by_type).and_return(bulk_data)

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(new_sync.id)
      end

      new_sync.reload
      expect(new_sync).to be_failed
      expect(new_sync.error_message).to include "Already have the latest version"
    end

    it "downloads newer version when available" do
      # Create existing sync with old version
      existing_sync = create(:scryfall_sync, :completed,
                           sync_type: "oracle_cards",
                           version: "2025-01-14")

      # Try new sync with newer version
      new_sync = create(:scryfall_sync, sync_type: "oracle_cards")

      bulk_data = double("BulkData",
                        updated_at: "2025-01-15", # Newer version
                        download_uri: "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json",
                        size: 1000)
      allow(Scryfall::BulkData).to receive(:find_by_type).and_return(bulk_data)

      stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
        .to_return(
          status: 200,
          body: File.read(Rails.root.join("spec/fixtures/files/oracle_cards_sample.json")),
          headers: {"Content-Length" => "1000"}
        )

      # Mock mapper
      card_mapper = instance_double(Scryfall::CardMapper)
      allow(Scryfall::CardMapper).to receive(:new).and_return(card_mapper)
      allow(card_mapper).to receive(:import_oracle_card)

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(new_sync.id)
      end

      new_sync.reload
      expect(new_sync).to be_completed
      expect(new_sync.version).to eq "2025-01-15"
    end
  end

  describe "error recovery" do
    let(:sync) { create(:scryfall_sync, sync_type: "oracle_cards") }

    it "handles network failures gracefully" do
      allow(Scryfall::BulkData).to receive(:find_by_type)
        .and_raise(Net::OpenTimeout, "Connection timeout")

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      sync.reload
      expect(sync).to be_failed
      expect(sync.error_message).to include "Connection timeout"
    end

    it "handles malformed JSON gracefully" do
      bulk_data = double("BulkData",
                        updated_at: "2025-01-15",
                        download_uri: "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json",
                        size: 100)
      allow(Scryfall::BulkData).to receive(:find_by_type).and_return(bulk_data)

      stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
        .to_return(
          status: 200,
          body: File.read(Rails.root.join("spec/fixtures/files/malformed.json")),
          headers: {"Content-Length" => "100"}
        )

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      sync.reload
      expect(sync).to be_completed
      # Processing should complete even with malformed data
      expect(sync.processing_status).to eq "completed"
      expect(sync.total_records).to eq 0 # No valid records
    end
  end

  describe "file management" do
    it "cleans up old files after successful sync" do
      # Create old sync with file
      old_sync = create(:scryfall_sync, :completed,
                       sync_type: "oracle_cards",
                       file_path: "/old/file.json")

      # Mock file existence
      allow(File).to receive(:exist?).with("/old/file.json").and_return(true)
      expect(File).to receive(:delete).with("/old/file.json")

      # New sync
      new_sync = create(:scryfall_sync, sync_type: "oracle_cards")

      bulk_data = double("BulkData",
                        updated_at: "2025-01-16",
                        download_uri: "https://data.scryfall.io/oracle-cards/oracle-cards-20250116.json",
                        size: 1000)
      allow(Scryfall::BulkData).to receive(:find_by_type).and_return(bulk_data)

      stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250116.json")
        .to_return(
          status: 200,
          body: '{"test": "data"}',
          headers: {"Content-Length" => "16"}
        )

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(new_sync.id)
      end

      old_sync.reload
      expect(old_sync.file_path).to be_nil
    end
  end

  describe "performance" do
    it "processes large datasets with batching" do
      sync = create(:scryfall_sync, sync_type: "oracle_cards", batch_size: 100)

      # Create large dataset
      large_dataset = 1000.times.map do |i|
        {
          oracle_id: "id-#{i}",
          name: "Card #{i}",
          mana_cost: "{1}",
          cmc: 1.0,
          type_line: "Creature",
          oracle_text: "Test",
          colors: [],
          color_identity: [],
          layout: "normal",
          legalities: {commander: "legal"}
        }.to_json
      end.join("\n")

      bulk_data = double("BulkData",
                        updated_at: "2025-01-15",
                        download_uri: "https://data.scryfall.io/large-dataset.json",
                        size: large_dataset.bytesize)
      allow(Scryfall::BulkData).to receive(:find_by_type).and_return(bulk_data)

      stub_request(:get, "https://data.scryfall.io/large-dataset.json")
        .to_return(
          status: 200,
          body: large_dataset,
          headers: {"Content-Length" => large_dataset.bytesize.to_s}
        )

      card_mapper = instance_double(Scryfall::CardMapper)
      allow(Scryfall::CardMapper).to receive(:new).and_return(card_mapper)
      allow(card_mapper).to receive(:import_oracle_card)

      perform_enqueued_jobs do
        ScryfallSyncJob.perform_later(sync.id)
      end

      sync.reload
      expect(sync.processing_status).to eq "completed"
      expect(sync.total_records).to eq 1000
      expect(sync.processed_records).to eq 1000
      # Should have created 10 batches (1000 records / 100 batch_size)
      expect(sync.last_processed_batch).to eq 10
    end
  end
end
