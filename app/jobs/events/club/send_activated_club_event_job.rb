module Events
  module Club
    class SendActivatedClubEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      attr_reader :user, :offer, :person_payment

      def perform(subscription:)
        @person_payment = subscription.person_payments.last
        @offer = person_payment.offer
        @user = person_payment.payer&.user
        EventServices::SendEvent.new(user: person_payment.payer.user,
                                     event: build_event(subscription)).call
      end

      private

      def build_event(subscription)
        OpenStruct.new({
                         name: 'club',
                         data: {
                           type: 'new_subscription',
                           subscription_id: subscription.id,
                           integration_id: person_payment.integration_id,
                           currency: person_payment.currency,
                           platform: person_payment.platform,
                           amount: person_payment.formatted_amount,
                           status: subscription.status,
                           offer_id: person_payment.offer_id,
                           payment_day: person_payment.created_at.day
                         }
                       })
      end
    end
  end
end
