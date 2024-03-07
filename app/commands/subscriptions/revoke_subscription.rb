module Subscriptions
  class RevokeSubscription < ApplicationCommand
    prepend SimpleCommand
    attr_reader :subscription

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      ActiveRecord::Base.transaction do
        subscription.update!(status: :inactive)
      end
    rescue StandardError => e
      errors.add(:message, e.message)
      Reporter.log(error: e)
    end
  end
end
