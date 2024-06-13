module Subscriptions
  class UpdateNextPaymentAttempt
    prepend SimpleCommand
    attr_reader :subscription

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      subscription.update!(next_payment_attempt: 1.month.from_now)
    end
  end
end
