module Events
  module Club
    class SendCanceledClubEventJob < ApplicationJob
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
                           type: 'cancellation_confirmation',
                           subscription_id: subscription.id,
                           integration_id: subscription.integration_id,
                           currency: subscription.offer.currency,
                           platform: subscription.platform,
                           amount: subscription.formatted_amount,
                           status: subscription.status,
                           offer_id: subscription.offer_id,
                           last_club_day: subscription.last_club_day&.strftime('%d/%m/%Y')
                         }
                       })
      end
    end
  end
end
