module Tracking
  class AddUtmJob < ApplicationJob
    queue_as :default

    def perform(utm_params:, trackable:)
      AddUtm.call(utm_params:, trackable:)
    end
  end
end
