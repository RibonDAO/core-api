module Subscriptions
  class RevokeSubscriptionJob < ApplicationJob
    queue_as :default

    def perform(subscription)
      Subscriptions::RevokeSubscription.call(subscription:)
    end
  end
end
