module Subscriptions
  class UpdateDirectTransferSubscriptionJob < ApplicationJob
    queue_as :subscriptions

    def perform
      subscriptions_direct_transfer.each do |subscription|
        Subscriptions::UpdateLastClubDay.call(subscription:)
      end
    end

    def subscriptions_direct_transfer
      Subscription.where(person_payment: :direct_transfer, status: :active)
                  .where(next_payment_attempt: Time.zone.now)
    end
  end
end
