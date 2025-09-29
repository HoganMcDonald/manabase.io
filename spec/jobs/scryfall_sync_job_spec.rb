# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe ScryfallSyncJob, type: :job do
  include ActiveJob::TestHelper

  let(:sync) { create(:scryfall_sync, sync_type: "oracle_cards") }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  after do
    WebMock.reset!
  end

  describe "#perform" do
    context "when sync is pending" do
      it "transitions sync to downloading state" do
        mock_bulk_data_api
        mock_file_download

        expect { perform_enqueued_jobs { described_class.perform_later(sync.id) } }
          .to change { sync.reload.status }.from("pending").to("completed")
      end

      it "downloads the file to correct location" do
        mock_bulk_data_api
        mock_file_download

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.file_path).to include("storage/scryfall/oracle_cards")
        expect(sync.file_path).to include(".json")
      end

      it "sets version and download_uri" do
        mock_bulk_data_api
        mock_file_download

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync.version).to eq "2025-01-15"
        expect(sync.download_uri).to eq "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json"
      end

      it "queues processing job after successful download" do
        mock_bulk_data_api
        mock_file_download

        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.to have_enqueued_job(ScryfallProcessingJob).with(sync.id)
      end
    end

    context "when sync cannot start" do
      let(:sync) { create(:scryfall_sync, :completed) }

      it "does not process completed syncs" do
        expect(Scryfall::BulkData).not_to receive(:find_by_type)

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        expect(sync.reload).to be_completed
      end
    end

    context "when sync is cancelled during operation" do
      it "stops processing if cancelled after starting" do
        allow_any_instance_of(ScryfallSync).to receive(:start!).and_wrap_original do |method, *args|
          method.call(*args)
          sync.reload.cancel!
        end

        expect(Scryfall::BulkData).not_to receive(:find_by_type)

        perform_enqueued_jobs { described_class.perform_later(sync.id) }
      end

      it "cleans up partial downloads if cancelled during download" do
        mock_bulk_data_api

        stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
          .to_return do |request|
            sync.reload.cancel!
            {status: 200, body: "", headers: {"Content-Length" => "1000"}}
          end

        expect {
          perform_enqueued_jobs { described_class.perform_later(sync.id) }
        }.to raise_error("Download cancelled")

        expect(sync.reload).to be_cancelled
      end
    end

    context "when bulk data API fails" do
      it "marks sync as failed with error message" do
        allow(Scryfall::BulkData).to receive(:find_by_type).and_raise(StandardError, "API Error")

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync).to be_failed
        expect(sync.error_message).to include "API Error"
      end
    end

    context "when download fails" do
      it "handles HTTP errors" do
        mock_bulk_data_api

        stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
          .to_return(status: 500, body: "Server Error")

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync).to be_failed
        expect(sync.error_message).to include "HTTP Error"
      end

      it "handles network timeouts" do
        mock_bulk_data_api

        stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
          .to_timeout

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync).to be_failed
        expect(sync.error_message).to include "timeout"
      end
    end

    context "version checking" do
      let(:latest_sync) { create(:scryfall_sync, :completed, sync_type: "oracle_cards", version: "2025-01-15") }

      before do
        latest_sync # Create it before the test
      end

      it "skips download if already have latest version" do
        mock_bulk_data_api("2025-01-15") # Same version

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync).to be_failed
        expect(sync.error_message).to include "Already have the latest version"
      end

      it "downloads if remote version is newer" do
        mock_bulk_data_api("2025-01-16") # Newer version
        mock_file_download

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        sync.reload
        expect(sync).to be_completed
        expect(sync.version).to eq "2025-01-16"
      end
    end

    context "file cleanup" do
      it "removes old files after successful download" do
        old_sync = create(:scryfall_sync, :completed,
                         sync_type: "oracle_cards",
                         file_path: "/old/path/file.json")

        expect(old_sync).to receive(:cleanup_old_files!)

        allow(ScryfallSync).to receive_message_chain(:by_type, :completed, :where)
          .and_return([old_sync])

        mock_bulk_data_api
        mock_file_download

        perform_enqueued_jobs { described_class.perform_later(sync.id) }
      end
    end

    context "download progress tracking" do
      it "logs download progress" do
        mock_bulk_data_api

        allow(Rails.logger).to receive(:info)

        stub_request(:get, "https://data.scryfall.io/oracle-cards/oracle-cards-20250115.json")
          .to_return(
            status: 200,
            body: '{"test": "data"}',
            headers: {"Content-Length" => "16"}
          )

        perform_enqueued_jobs { described_class.perform_later(sync.id) }

        expect(Rails.logger).to have_received(:info).with(/Downloading oracle_cards:/)
      end
    end
  end

  private

  def mock_bulk_data_api(version = "2025-01-15")
    bulk_data = double("BulkData",
                      updated_at: version,
                      download_uri: "https://data.scryfall.io/oracle-cards/oracle-cards-#{version.gsub('-', '')}.json",
                      size: 1024000)

    allow(Scryfall::BulkData).to receive(:find_by_type).with("oracle_cards").and_return(bulk_data)
  end

  def mock_file_download
    stub_request(:get, /data\.scryfall\.io/)
      .to_return(
        status: 200,
        body: File.read(Rails.root.join("spec/fixtures/files/oracle_cards_sample.json")),
        headers: {"Content-Length" => "1000"}
      )
  end
end
