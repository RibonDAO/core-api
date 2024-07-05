module Events
  module Club
    class SendActivatedClubEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      def perform(subscription:)
        EventServices::SendEvent.new(user: subscription.payer&.user,
                                     event: build_event(subscription)).call
      end

      private

      def build_event(subscription)
        OpenStruct.new({
                         name: 'club',
                         data: {
                           type: 'new_subscription',
                           subscription_id: subscription.id,
                           integration_id: subscription.integration_id,
                           currency: subscription.offer.currency,
                           platform: subscription.platform,
                           amount: subscription.formatted_amount,
                           status: subscription.status,
                           offer_id: subscription.offer_id,
                           payment_day: subscription.last_club_day&.day
                         }
                       })
      end
    end
  end
end
