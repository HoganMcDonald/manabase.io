# frozen_string_literal: true

require "database_cleaner/active_record"

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each, type: :integration) do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.cleaning do
      example.run
    end
    DatabaseCleaner.strategy = :transaction
  end
end
