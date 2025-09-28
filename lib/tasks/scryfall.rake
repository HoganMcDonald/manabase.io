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

  desc "Show status of Scryfall syncs"
  task status: :environment do
    puts "\nScryfall Sync Status:"
    puts "-" * 80

    ScryfallSync::VALID_SYNC_TYPES.each do |sync_type|
      latest = ScryfallSync.latest_for_type(sync_type)
      in_progress = ScryfallSync.sync_in_progress?(sync_type)

      status = if in_progress
                 "🔄 IN PROGRESS"
               elsif latest
                 "✅ #{latest.version} (#{latest.completed_at&.strftime('%Y-%m-%d %H:%M')})"
               else
                 "❌ Never synced"
               end

      puts "#{sync_type.ljust(20)} #{status}"
    end

    puts "-" * 80
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