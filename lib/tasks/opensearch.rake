# frozen_string_literal: true

namespace :opensearch do
  desc "Create OpenSearch index with mappings"
  task setup: :environment do
    puts "Creating OpenSearch index..."
    indexer = Search::CardIndexer.new

    if indexer.create_index
      puts "✓ OpenSearch index created successfully"
    else
      puts "✗ Failed to create OpenSearch index"
      exit 1
    end
  end

  desc "Delete OpenSearch index"
  task delete: :environment do
    puts "Deleting OpenSearch index..."
    indexer = Search::CardIndexer.new

    if indexer.delete_index
      puts "✓ OpenSearch index deleted successfully"
    else
      puts "✗ Failed to delete OpenSearch index"
      exit 1
    end
  end

  desc "Reset OpenSearch index (delete and recreate)"
  task reset: :environment do
    puts "Resetting OpenSearch index..."
    indexer = Search::CardIndexer.new

    indexer.delete_index
    sleep 1 # Give OpenSearch a moment to process the deletion

    if indexer.create_index
      puts "✓ OpenSearch index reset successfully"
    else
      puts "✗ Failed to reset OpenSearch index"
      exit 1
    end
  end

  desc "Reindex all cards in OpenSearch"
  task reindex: :environment do
    puts "Starting OpenSearch reindex..."

    sync = OpenSearchSync.create!
    puts "Created sync record: ##{sync.id}"

    begin
      OpenSearchReindexJob.perform_now(sync.id)
      sync.reload

      if sync.completed?
        puts "✓ Reindex completed successfully"
        puts "  Total cards: #{sync.total_cards}"
        puts "  Indexed: #{sync.indexed_cards}"
        puts "  Failed: #{sync.failed_cards}"
        puts "  Duration: #{sync.duration_formatted}"
      else
        puts "✗ Reindex failed"
        puts "  Error: #{sync.error_message}"
        exit 1
      end
    rescue StandardError => e
      puts "✗ Reindex failed with exception: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end

  desc "Show OpenSearch index status and statistics"
  task status: :environment do
    indexer = Search::CardIndexer.new

    puts "OpenSearch Status"
    puts "=" * 50

    if indexer.send(:index_exists?)
      stats = indexer.index_stats
      puts "Index: EXISTS"
      puts "Document count: #{stats[:document_count]}"
      puts "Size: #{(stats[:size_in_bytes].to_f / 1024 / 1024).round(2)} MB"
    else
      puts "Index: DOES NOT EXIST"
      puts "\nRun 'rake opensearch:setup' to create the index"
    end

    puts "\nRecent Syncs"
    puts "-" * 50

    recent_syncs = OpenSearchSync.recent.limit(5)
    if recent_syncs.any?
      recent_syncs.each do |sync|
        status_icon = case sync.status
        when "completed" then "✓"
        when "failed" then "✗"
        when "indexing" then "⟳"
        else "○"
        end

        puts "#{status_icon} ##{sync.id} - #{sync.status.upcase} - #{sync.created_at.strftime("%Y-%m-%d %H:%M:%S")}"
        if sync.total_cards > 0
          puts "  Progress: #{sync.indexed_cards}/#{sync.total_cards} (#{sync.progress_percentage}%)"
        end
        puts "  Duration: #{sync.duration_formatted}" if sync.duration
        puts "  Error: #{sync.error_message}" if sync.error_message.present?
      end
    else
      puts "No syncs found"
    end

    puts "\nDatabase Stats"
    puts "-" * 50
    puts "Total cards in database: #{Card.count}"
  end

  desc "Test OpenSearch connection"
  task test_connection: :environment do
    puts "Testing OpenSearch connection..."

    begin
      client = $OPENSEARCH_CLIENT
      info = client.info

      puts "✓ Successfully connected to OpenSearch"
      puts "  Version: #{info.dig("version", "number")}"
      puts "  Cluster: #{info["cluster_name"]}"
    rescue StandardError => e
      puts "✗ Failed to connect to OpenSearch"
      puts "  Error: #{e.message}"
      exit 1
    end
  end

  desc "Backfill embeddings for all cards"
  task backfill_embeddings: :environment do
    start_id = ENV["START_ID"]
    limit = ENV["LIMIT"]&.to_i

    puts "Starting embedding backfill..."
    puts "Start ID: #{start_id || 'beginning'}"
    puts "Limit: #{limit || 'all cards'}"
    puts "=" * 50

    result = EmbeddingBackfillJob.perform_now(start_id: start_id, limit: limit)

    puts "\n" + "=" * 50
    puts "Backfill complete!"
    puts "  Processed: #{result[:processed]}"
    puts "  Failed: #{result[:failed]}"
    puts "  Total: #{result[:total]}"
  rescue StandardError => e
    puts "✗ Backfill failed: #{e.message}"
    puts e.backtrace.first(5).join("\n")
    exit 1
  end

  desc "Test embedding generation"
  task test_embeddings: :environment do
    puts "Testing embedding generation..."
    puts "=" * 50

    test_texts = [
      "Lightning Bolt",
      "cards that let you draw cards when creatures die",
      "low cost sacrifice creatures"
    ]

    test_texts.each do |text|
      puts "\nGenerating embedding for: \"#{text}\""

      begin
        embedding = Search::EmbeddingService.embed(text)

        if embedding.present?
          puts "✓ Successfully generated embedding"
          puts "  Dimensions: #{embedding.length}"
          puts "  First 5 values: #{embedding.take(5).map { |v| v.round(4) }.join(", ")}"
        else
          puts "✗ Failed to generate embedding (returned nil)"
        end
      rescue StandardError => e
        puts "✗ Error generating embedding: #{e.message}"
        puts e.backtrace.first(3).join("\n")
      end
    end

    puts "\n" + "=" * 50
    puts "Testing card embedding..."

    begin
      card = Card.first
      if card
        puts "Card: #{card.name}"
        embedding = Search::EmbeddingService.embed_card(card)

        if embedding.present?
          puts "✓ Successfully generated card embedding"
          puts "  Dimensions: #{embedding.length}"
        else
          puts "✗ Failed to generate card embedding"
        end
      else
        puts "⚠ No cards found in database"
      end
    rescue StandardError => e
      puts "✗ Error: #{e.message}"
      puts e.backtrace.first(3).join("\n")
    end
  end
end
