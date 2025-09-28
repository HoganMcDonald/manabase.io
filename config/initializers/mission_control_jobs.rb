# frozen_string_literal: true

# Configure Mission Control Jobs
Rails.application.configure do
  # Disable built-in HTTP basic authentication
  config.mission_control.jobs.http_basic_auth_enabled = false

  # Optional: Configure which queues to display
  # config.mission_control.jobs.queues = %w[ default urgent ]

  # Optional: Configure how many jobs to show per page
  # config.mission_control.jobs.jobs_per_page = 20
end

# Override the BasicAuthentication concern to use our app's authentication
module MissionControl
  module Jobs
    module BasicAuthentication
      extend ActiveSupport::Concern

      included do
        # Remove the original before_action
        skip_before_action :authenticate_by_http_basic, raise: false

        # Skip the application's default authenticate and use admin requirement
        skip_before_action :authenticate, raise: false
        before_action :require_admin
      end

      private

      # Override the method to prevent HTTP basic auth
      def authenticate_by_http_basic
        # Do nothing - we're using our own authentication
      end
    end
  end
end