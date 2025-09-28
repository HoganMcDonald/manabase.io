#!/usr/bin/env ruby

require 'json'
require 'set'

class ScryfallSchemaAnalyzer
  def initialize
    @field_info = {}
    @total_objects = 0
    @sample_values = {}
    @array_element_types = {}
    @nested_object_schemas = {}
  end

  def analyze_file(filepath)
    puts "Analyzing: #{filepath}"

    File.open(filepath, 'r') do |file|
      parser = JSON::Stream::Parser.new
      current_object = {}
      in_array = false
      array_started = false

      parser.start_array {
        if !array_started
          in_array = true
          array_started = true
        end
      }

      parser.end_array { in_array = false }

      parser.start_object { current_object = {} if in_array }

      parser.key { |key| @current_key = key if in_array }

      parser.value do |value|
        if in_array && @current_key
          current_object[@current_key] = value
        end
      end

      parser.end_object do
        if in_array && !current_object.empty?
          analyze_object(current_object)
          @total_objects += 1

          if @total_objects % 1000 == 0
            print "\rProcessed #{@total_objects} objects..."
          end
        end
      end

      # Stream parse the file
      chunk_size = 1024 * 1024 # 1MB chunks
      while chunk = file.read(chunk_size)
        parser << chunk
      end
    end

    puts "\nTotal objects analyzed: #{@total_objects}"
  rescue => e
    puts "Error parsing with streaming, trying alternative approach: #{e.message}"
    analyze_file_alternative(filepath)
  end

  def analyze_file_alternative(filepath)
    line_buffer = ""
    object_depth = 0
    in_main_array = false

    File.foreach(filepath) do |line|
      line.strip!

      # Detect start of main array
      if !in_main_array && line.start_with?('[')
        in_main_array = true
        line = line[1..-1].strip
      end

      next if line.empty? || !in_main_array

      # Handle end of array
      if line.end_with?(']')
        line = line[0..-2].strip
        in_main_array = false if object_depth == 0
      end

      line_buffer += line

      # Count braces to track object boundaries
      object_depth += line.count('{') - line.count('}')

      # When we have a complete object
      if object_depth == 0 && line_buffer.include?('{')
        # Remove trailing comma if present
        line_buffer = line_buffer.rstrip.chomp(',')

        begin
          if line_buffer.start_with?('{') && line_buffer.end_with?('}')
            object = JSON.parse(line_buffer)
            analyze_object(object)
            @total_objects += 1

            if @total_objects % 1000 == 0
              print "\rProcessed #{@total_objects} objects..."
            end
          end
        rescue JSON::ParserError => e
          # Skip malformed objects
        end

        line_buffer = ""
      end
    end

    puts "\nTotal objects analyzed: #{@total_objects}"
  end

  def analyze_object(obj, prefix = "")
    obj.each do |key, value|
      field_path = prefix.empty? ? key : "#{prefix}.#{key}"

      # Initialize field info
      @field_info[field_path] ||= {
        count: 0,
        types: Set.new,
        nullable: false,
        min_value: nil,
        max_value: nil,
        unique_values: Set.new,
        is_array: false,
        array_types: Set.new,
        nested_schema: {}
      }

      @field_info[field_path][:count] += 1

      # Analyze the value
      case value
      when NilClass
        @field_info[field_path][:nullable] = true
        @field_info[field_path][:types] << 'null'
      when String
        @field_info[field_path][:types] << 'string'
        add_sample_value(field_path, value)
      when Integer
        @field_info[field_path][:types] << 'integer'
        update_min_max(field_path, value)
      when Float
        @field_info[field_path][:types] << 'float'
        update_min_max(field_path, value)
      when TrueClass, FalseClass
        @field_info[field_path][:types] << 'boolean'
        add_sample_value(field_path, value.to_s)
      when Array
        @field_info[field_path][:types] << 'array'
        @field_info[field_path][:is_array] = true

        # Analyze array elements
        value.each do |element|
          case element
          when Hash
            @field_info[field_path][:array_types] << 'object'
            analyze_object(element, "#{field_path}[]")
          else
            @field_info[field_path][:array_types] << element.class.name.downcase
          end
        end

        add_sample_value(field_path, "Array[#{value.size}]")
      when Hash
        @field_info[field_path][:types] << 'object'
        analyze_object(value, field_path)
      end
    end
  end

  def add_sample_value(field_path, value)
    @sample_values[field_path] ||= Set.new
    if @sample_values[field_path].size < 5
      @sample_values[field_path] << value.to_s[0..100]
    end
  end

  def update_min_max(field_path, value)
    if @field_info[field_path][:min_value].nil? || value < @field_info[field_path][:min_value]
      @field_info[field_path][:min_value] = value
    end
    if @field_info[field_path][:max_value].nil? || value > @field_info[field_path][:max_value]
      @field_info[field_path][:max_value] = value
    end
  end

  def generate_report(output_file)
    File.open(output_file, 'w') do |f|
      f.puts "# Scryfall Data Schema Analysis"
      f.puts "# Total objects analyzed: #{@total_objects}"
      f.puts "# Generated at: #{Time.now}"
      f.puts "#" + "=" * 80
      f.puts

      # Group fields by parent
      root_fields = {}
      nested_fields = {}

      @field_info.each do |field_path, info|
        if field_path.include?('.')
          parent = field_path.split('.').first
          nested_fields[parent] ||= []
          nested_fields[parent] << [field_path, info]
        else
          root_fields[field_path] = info
        end
      end

      # Sort and output root fields
      root_fields.sort_by { |k, _| k }.each do |field, info|
        occurrence_rate = (info[:count].to_f / @total_objects * 100).round(2)
        optional = occurrence_rate < 100

        f.puts "## Field: #{field}"
        f.puts "  Required: #{optional ? 'NO (Optional)' : 'YES'}"
        f.puts "  Occurrence: #{occurrence_rate}% (#{info[:count]}/#{@total_objects})"
        f.puts "  Types: #{info[:types].to_a.join(', ')}"
        f.puts "  Nullable: #{info[:nullable]}"

        if info[:is_array] && !info[:array_types].empty?
          f.puts "  Array Element Types: #{info[:array_types].to_a.join(', ')}"
        end

        if info[:min_value] || info[:max_value]
          f.puts "  Range: #{info[:min_value]} to #{info[:max_value]}"
        end

        if @sample_values[field] && !@sample_values[field].empty?
          f.puts "  Sample Values:"
          @sample_values[field].each { |v| f.puts "    - #{v}" }
        end

        # Output nested fields if any
        if nested_fields[field]
          f.puts "  Nested Schema:"
          nested_fields[field].sort_by { |k, _| k }.each do |nested_field, nested_info|
            nested_occurrence = (nested_info[:count].to_f / info[:count] * 100).round(2)
            indent = "    " * (nested_field.count('.') + 1)
            field_name = nested_field.split('.').last

            f.puts "#{indent}#{field_name}:"
            f.puts "#{indent}  Occurrence in parent: #{nested_occurrence}%"
            f.puts "#{indent}  Types: #{nested_info[:types].to_a.join(', ')}"

            if nested_info[:nullable]
              f.puts "#{indent}  Nullable: true"
            end

            if nested_info[:is_array] && !nested_info[:array_types].empty?
              f.puts "#{indent}  Array Types: #{nested_info[:array_types].to_a.join(', ')}"
            end
          end
        end

        f.puts
      end

      # Summary section
      f.puts "#" * 80
      f.puts "# SUMMARY"
      f.puts
      f.puts "## Required Fields (100% occurrence):"
      root_fields.each do |field, info|
        if (info[:count].to_f / @total_objects * 100).round(2) == 100
          f.puts "  - #{field} (#{info[:types].to_a.join(', ')})"
        end
      end

      f.puts
      f.puts "## Optional Fields (<100% occurrence):"
      root_fields.each do |field, info|
        occurrence = (info[:count].to_f / @total_objects * 100).round(2)
        if occurrence < 100
          f.puts "  - #{field} (#{occurrence}%, #{info[:types].to_a.join(', ')})"
        end
      end

      f.puts
      f.puts "## Fields with Multiple Types:"
      @field_info.each do |field, info|
        if info[:types].size > 1
          f.puts "  - #{field}: #{info[:types].to_a.join(', ')}"
        end
      end
    end

    puts "\nReport saved to: #{output_file}"
  end
end

# Check if json-stream gem is available, if not use alternative parsing
begin
  require 'json/stream'
rescue LoadError
  puts "json-stream gem not found. Using alternative line-by-line parsing."
  puts "For better performance, install: gem install json-stream"
end

# Main execution
if ARGV.empty?
  puts "Usage: ruby analyze_scryfall_schema.rb <json_file_path> [output_file]"
  puts "Example: ruby analyze_scryfall_schema.rb oracle-cards.json oracle-schema.txt"
  exit 1
end

input_file = ARGV[0]
output_file = ARGV[1] || "#{File.basename(input_file, '.*')}_schema.txt"

unless File.exist?(input_file)
  puts "Error: File '#{input_file}' not found"
  exit 1
end

analyzer = ScryfallSchemaAnalyzer.new
analyzer.analyze_file(input_file)
analyzer.generate_report(output_file)