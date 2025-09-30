# frozen_string_literal: true

namespace :scryfall do
  namespace :analyze do
    desc "Analyze structure of Scryfall oracle cards data"
    task oracle_cards: :environment do
      analyze_bulk_data("oracle_cards")
    end

    desc "Analyze structure of Scryfall unique artwork data"
    task unique_artwork: :environment do
      analyze_bulk_data("unique_artwork")
    end

    desc "Analyze structure of Scryfall default cards data"
    task default_cards: :environment do
      analyze_bulk_data("default_cards")
    end

    desc "Analyze structure of Scryfall all cards data"
    task all_cards: :environment do
      analyze_bulk_data("all_cards")
    end

    desc "Analyze structure of Scryfall rulings data"
    task rulings: :environment do
      analyze_bulk_data("rulings")
    end
  end

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
    puts "  Cards (Oracle): #{Card.count}"
    puts "  Card Sets: #{CardSet.count}"
    puts "  Card Printings: #{CardPrinting.count}"
    puts "  Card Faces: #{CardFace.count}"
    puts "  Card Rulings: #{CardRuling.count}"
    puts "  Card Legalities: #{CardLegality.count}"
    puts "  Related Cards: #{RelatedCard.count}"
    puts "  Scryfall Syncs: #{ScryfallSync.count}"
  end

  def analyze_bulk_data(bulk_data_type)
    require 'json'
    require 'yaml'

    # Find the latest completed sync for this type
    latest_sync = ScryfallSync.by_type(bulk_data_type).completed.order(completed_at: :desc).first

    unless latest_sync && latest_sync.file_path && File.exist?(latest_sync.file_path)
      puts "\nError: No downloaded #{bulk_data_type} file found."
      puts "Please run: rake scryfall:sync:#{bulk_data_type}"
      exit 1
    end

    source_file = latest_sync.file_path
    output_file = source_file.sub(/\.json$/, '_structure.yml')

    puts "\nAnalyzing #{bulk_data_type} structure..."
    puts "Source: #{source_file}"
    puts "Output: #{output_file}"
    puts "-" * 60

    # Initialize structure tracker
    structure = {}
    total_records = 0
    start_time = Time.now
    last_progress_time = Time.now

    # First pass: count total records for progress tracking
    puts "\nCounting records..."
    File.open(source_file, 'r') do |file|
      file.each_line do |line|
        total_records += 1 if line.strip.start_with?('{')
      end
    end
    puts "Total records: #{total_records}"
    puts "\nAnalyzing structure..."

    # Second pass: analyze structure
    current_record = 0

    File.open(source_file, 'r') do |file|
      file.each_line do |line|
        line = line.strip
        next if line.empty? || line == '[' || line == ']'

        # Remove trailing comma if present
        line = line.chomp(',') if line.end_with?(',')

        # Skip if not a JSON object
        next unless line.start_with?('{') && line.end_with?('}')

        current_record += 1

        # Parse JSON
        begin
          record = JSON.parse(line)
          analyze_record_structure(record, structure)
        rescue JSON::ParserError => e
          puts "Warning: Failed to parse record #{current_record}: #{e.message}"
          next
        end

        # Progress tracking with ETA
        if current_record % 100 == 0 || current_record == total_records
          elapsed = Time.now - start_time
          rate = current_record / elapsed.to_f
          remaining = (total_records - current_record) / rate

          progress = (current_record.to_f / total_records * 100).round(1)
          eta = remaining > 0 ? Time.now + remaining : Time.now

          # Only update if at least 0.5 seconds have passed since last update
          if Time.now - last_progress_time > 0.5 || current_record == total_records
            print "\rProgress: #{current_record}/#{total_records} (#{progress}%) | "
            print "Rate: #{rate.round(0)}/sec | "
            print "ETA: #{eta.strftime('%H:%M:%S')}          "
            last_progress_time = Time.now
          end
        end
      end
    end

    puts "\n\nProcessing complete. Generating structure report..."

    # Convert structure to final format with statistics
    final_structure = convert_to_final_structure(structure, total_records)

    # Write YAML output
    File.write(output_file, final_structure.to_yaml)

    # Summary
    puts "\n" + "=" * 60
    puts "Analysis Complete!"
    puts "=" * 60
    puts "Records analyzed: #{total_records}"
    puts "Time taken: #{(Time.now - start_time).round(1)} seconds"
    puts "Output saved to: #{output_file}"
    puts "\nTop-level fields found: #{final_structure['fields'].keys.size}"
    puts "\nUse 'cat #{output_file}' to view the full structure"
  end

  def analyze_record_structure(record, structure, path = [])
    record.each do |key, value|
      field_path = (path + [key]).join('.')
      field_path = key if path.empty?

      structure[field_path] ||= {
        types: Set.new,
        count: 0,
        sample_values: [],
        nested_fields: {}
      }

      structure[field_path][:count] += 1

      # Determine type and handle nested structures
      case value
      when NilClass
        structure[field_path][:types] << 'null'
      when String
        structure[field_path][:types] << 'string'
        if structure[field_path][:sample_values].size < 3 && !structure[field_path][:sample_values].include?(value)
          structure[field_path][:sample_values] << value.truncate(50)
        end
      when Integer
        structure[field_path][:types] << 'integer'
        if structure[field_path][:sample_values].size < 3
          structure[field_path][:sample_values] << value
        end
      when Float
        structure[field_path][:types] << 'float'
        if structure[field_path][:sample_values].size < 3
          structure[field_path][:sample_values] << value
        end
      when TrueClass, FalseClass
        structure[field_path][:types] << 'boolean'
        structure[field_path][:sample_values] << value if structure[field_path][:sample_values].size < 2
      when Hash
        structure[field_path][:types] << 'object'
        analyze_record_structure(value, structure, path + [key])
      when Array
        structure[field_path][:types] << 'array'
        structure[field_path][:array_size] ||= []
        structure[field_path][:array_size] << value.size

        # Analyze array element types
        value.each do |element|
          if element.is_a?(Hash)
            analyze_record_structure(element, structure, path + [key, '[]'])
          elsif !element.nil?
            array_element_path = (path + [key, '[]']).join('.')
            structure[array_element_path] ||= {
              types: Set.new,
              count: 0,
              sample_values: [],
              nested_fields: {}
            }
            structure[array_element_path][:count] += 1
            structure[array_element_path][:types] << element.class.name.downcase
          end
        end
      end
    end
  end

  def convert_to_final_structure(structure, total_records)
    result = {
      'metadata' => {
        'total_records' => total_records,
        'analyzed_at' => Time.now.iso8601,
        'fields_count' => structure.keys.size
      },
      'fields' => {}
    }

    structure.each do |field_path, info|
      field_info = {
        'types' => info[:types].to_a.sort,
        'occurrence_rate' => "#{(info[:count].to_f / total_records * 100).round(2)}%",
        'occurrences' => info[:count],
        'required' => info[:count] == total_records
      }

      field_info['sample_values'] = info[:sample_values] unless info[:sample_values].empty?

      if info[:array_size] && !info[:array_size].empty?
        field_info['array_stats'] = {
          'min_size' => info[:array_size].min,
          'max_size' => info[:array_size].max,
          'avg_size' => (info[:array_size].sum.to_f / info[:array_size].size).round(2)
        }
      end

      result['fields'][field_path] = field_info
    end

    # Sort fields for readability
    result['fields'] = result['fields'].sort.to_h

    result
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
