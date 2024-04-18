module Tracking
  class AddUtmJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(utm_params:, trackable:)
      AddUtm.call(utm_params:, trackable:)
    end
  end
end
