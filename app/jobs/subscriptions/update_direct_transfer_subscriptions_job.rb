module Subscriptions
  class UpdateDirectTransferSubscriptionsJob < ApplicationJob
    queue_as :subscriptions

    def perform
      subscriptions_direct_transfer.each do |subscription|
        Subscriptions::UpdateNextPaymentAttempt.call(subscription:)
      end
    end

    def subscriptions_direct_transfer
      Subscription.where(payment_method: :direct_transfer, status: :active)
                  .where('date(next_payment_attempt)= ?', Time.zone.today)
    end
  end
end
