# frozen_string_literal: true

# Configure Redis connection for Sidekiq
redis_config = {
  url: ENV.fetch("REDIS_URL") do
    host = ENV.fetch("REDIS_HOST", "localhost")
    port = ENV.fetch("REDIS_PORT", 6379)
    db = ENV.fetch("REDIS_DB", 0)
    "redis://#{host}:#{port}/#{db}"
  end,
  network_timeout: 5
}

Sidekiq.configure_server do |config|
  config.redis = redis_config

  # Load recurring jobs schedule
  schedule_file = Rails.root.join("config", "schedule.yml")
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(schedule_file))
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
