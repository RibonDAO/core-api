module Subscriptions
  class RevokeSubscriptionJob < ApplicationJob
    queue_as :subscriptions

    def perform(subscription)
      Subscriptions::RevokeSubscription.call(subscription:)
    end
  end
end
