# frozen_string_literal: true

namespace :scryfall do
  namespace :sync do
    desc "Sync Scryfall oracle cards bulk data"
    task oracle_cards: :environment do
      enqueue_sync("oracle_cards")
    end

    desc "Sync Scryfall unique artwork bulk data"
    task unique_artwork: :environment do
      enqueue_sync("unique_artwork")
    end

    desc "Sync Scryfall default cards bulk data"
    task default_cards: :environment do
      enqueue_sync("default_cards")
    end

    desc "Sync Scryfall all cards bulk data"
    task all_cards: :environment do
      enqueue_sync("all_cards")
    end

    desc "Sync Scryfall rulings bulk data"
    task rulings: :environment do
      enqueue_sync("rulings")
    end

    desc "Sync all Scryfall bulk data types"
    task all: :environment do
      ScryfallSync::VALID_SYNC_TYPES.each do |sync_type|
        enqueue_sync(sync_type)
      end
    end
  end

  desc "Sync Scryfall bulk data of specified type"
  task :sync, [:bulk_data_type] => :environment do |_task, args|
    bulk_data_type = args[:bulk_data_type]

    unless bulk_data_type
      puts "Error: Please specify a bulk data type"
      puts "Usage: rake scryfall:sync[oracle_cards]"
      puts "Available types: #{ScryfallSync::VALID_SYNC_TYPES.join(', ')}"
      exit 1
    end

    unless ScryfallSync::VALID_SYNC_TYPES.include?(bulk_data_type)
      puts "Error: Invalid bulk data type: #{bulk_data_type}"
      puts "Available types: #{ScryfallSync::VALID_SYNC_TYPES.join(', ')}"
      exit 1
    end

    enqueue_sync(bulk_data_type)
  end

  desc "Process already downloaded Scryfall data"
  task :process, [:sync_type] => :environment do |_task, args|
    sync_type = args[:sync_type]

    unless sync_type
      puts "Error: Please specify a sync type to process"
      puts "Usage: rake scryfall:process[rulings]"
      puts "Available types: #{ScryfallSync::VALID_SYNC_TYPES.join(', ')}"
      exit 1
    end

    latest = ScryfallSync.latest_for_type(sync_type)

    unless latest
      puts "Error: No completed sync found for #{sync_type}"
      puts "Run 'rake scryfall:sync[#{sync_type}]' first to download the data"
      exit 1
    end

    unless latest.file_path && File.exist?(latest.file_path)
      puts "Error: Downloaded file not found for #{sync_type}"
      exit 1
    end

    if latest.processing? || latest.processing_queued?
      puts "Processing already in progress for #{sync_type}"
      exit 0
    end

    # Queue the processing job
    ScryfallProcessingJob.perform_later(latest.id)
    puts "Queued processing job for #{sync_type} (sync_id: #{latest.id})"
    puts "Run 'rake scryfall:status' to check progress"
  end

  desc "Show status of Scryfall syncs"
  task status: :environment do
    puts "\nScryfall Sync Status:"
    puts "-" * 100

    # Header
    puts "#{' Type'.ljust(20)} #{'Status'.ljust(15)} #{'Download'.ljust(25)} #{'Processing'.ljust(35)}"
    puts "-" * 100

    ScryfallSync::VALID_SYNC_TYPES.each do |sync_type|
      latest = ScryfallSync.latest_for_type(sync_type)
      active_sync = ScryfallSync.by_type(sync_type).pending_or_downloading.first

      # Determine download status
      download_status = if active_sync
        if active_sync.downloading?
          "🔄 Downloading"
        else
          "⏳ Pending"
        end
      elsif latest
        "✅ Complete"
      else
        "❌ Never synced"
      end

      # Download info
      download_info = if latest
        "v#{latest.version} (#{latest.completed_at&.strftime('%m/%d %H:%M')})"
      else
        "-"
      end

      # Processing info
      processing_info = if latest
        case latest.processing_status
        when "processing"
          progress = latest.processing_progress_percentage
          "🔄 #{progress}% (#{latest.processed_records}/#{latest.total_records})"
        when "completed"
          "✅ #{latest.processed_records} records"
        when "failed"
          "❌ Failed: #{latest.error_message&.truncate(20)}"
        when "queued"
          "⏳ Queued"
        else
          "⚪ Not started"
        end
      else
        "-"
      end

      puts "#{sync_type.ljust(20)} #{download_status.ljust(15)} #{download_info.ljust(25)} #{processing_info.ljust(35)}"
    end

    puts "-" * 100

    # Show active jobs count
    active_jobs = SolidQueue::Job.where(finished_at: nil)
    processing_jobs = active_jobs.where("class_name IN (?)", ["ScryfallProcessingJob", "ScryfallBatchImportJob"])

    if processing_jobs.any?
      puts "\nActive Jobs:"
      puts "  Processing: #{processing_jobs.where(class_name: 'ScryfallProcessingJob').count}"
      puts "  Batch Import: #{processing_jobs.where(class_name: 'ScryfallBatchImportJob').count}"
    end

    # Show database statistics
    puts "\nDatabase Statistics:"
    puts "  Cards: #{Card.count}"
    puts "  Card Sets: #{CardSet.count}"
    puts "  Card Printings: #{CardPrinting.count}"
    puts "  Card Rulings: #{CardRuling.count}"
    puts "  Card Legalities: #{CardLegality.count}"
  end

  def enqueue_sync(bulk_data_type)
    if ScryfallSync.sync_in_progress?(bulk_data_type)
      puts "Sync already in progress for #{bulk_data_type}"
      return
    end

    sync = ScryfallSync.create!(
      sync_type: bulk_data_type,
      status: "pending"
    )

    ScryfallSyncJob.perform_later(sync.id)

    puts "Enqueued sync job for #{bulk_data_type} (sync_id: #{sync.id})"
    puts "Run 'rake scryfall:status' to check progress"
  end
end
