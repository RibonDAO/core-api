module Subscriptions
  class UpdateSubscriptionAttributeJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(subscription, attributes)
      subscription&.update(attributes)
    end
  end
end
