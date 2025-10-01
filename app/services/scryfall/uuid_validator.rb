# frozen_string_literal: true

module Scryfall
  module UuidValidator
    UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i.freeze

    def self.valid_uuid?(value)
      return false unless value.is_a?(String)

      value.match?(UUID_REGEX)
    end

    def self.validate_and_log(value, context = {})
      return value if valid_uuid?(value)
      return nil if value.nil?

      Rails.logger.warn "Invalid UUID '#{value}' encountered in #{context[:field] || 'unknown field'} for #{context[:record_type] || 'record'} #{context[:record_id] || 'unknown'}"

      # Track warning in sync if provided
      if context[:sync]
        context[:sync].add_warning("Invalid UUID: #{value}", context)
      end

      nil
    end

    # Helper to safely assign UUID values with validation and logging
    def self.safe_assign_uuid(record, field, value, context = {})
      validated_value = validate_and_log(value, context.merge(field: field))
      record.send("#{field}=", validated_value) if validated_value
      validated_value
    end
  end
end
