module Subscriptions
  class RevokeSubscription < ApplicationCommand
    prepend SimpleCommand
    attr_reader :subscription

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      subscription.update!(status: :inactive)
    rescue StandardError => e
      errors.add(:message, e.message)
      Reporter.log(error: e)
    end
  end
end
