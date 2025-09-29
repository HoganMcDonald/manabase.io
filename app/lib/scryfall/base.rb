# frozen_string_literal: true

require "active_resource"

module Scryfall
  class Base < ActiveResource::Base
    self.site = "https://api.scryfall.com"
    self.include_format_in_path = false
    self.format = :json

    class << self
      def collection_from_response(response)
        body = response.body
        body = JSON.parse(body) if body.is_a?(String)

        if body.is_a?(Hash)
          if body["data"]
            body["data"].map { |attrs| instantiate_record(attrs, {}) }
          elsif body["object"] == "list"
            []
          else
            [instantiate_record(body, {})]
          end
        else
          []
        end
      rescue JSON::ParserError
        []
      end

      def find_every(options)
        begin
          case from = options[:from]
          when Symbol
            instantiate_collection(get(from, options[:params]), options[:params])
          when String
            path = "#{from}#{query_string(options[:params])}"
            response = format.decode(connection.get(path, headers).body)
            collection_from_response(OpenStruct.new(body: response))
          else
            prefix_options, query_options = split_options(options[:params])
            path = collection_path(prefix_options, query_options)
            response = connection.get(path, headers)
            collection_from_response(response)
          end
        rescue ActiveResource::ResourceNotFound, ActiveResource::ConnectionError
          []
        end
      end
    end

    def last_updated
      Time.parse(updated_at) if respond_to?(:updated_at) && updated_at
    end

    def stale?(hours = 24)
      return true unless last_updated
      (Time.now - last_updated) > (hours * 3600)
    end
  end
end
