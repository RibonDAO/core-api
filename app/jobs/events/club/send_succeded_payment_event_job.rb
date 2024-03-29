module Events
  module Club
    class SendSuccededPaymentEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      attr_reader :user, :offer

      def perform(person_payment:)
        @offer = person_payment.offer
        @user = person_payment.payer&.user

        EventServices::SendEvent.new(user: person_payment.payer.user,
                                     event: build_event(person_payment)).call
      end

      private

      def build_event(person_payment)
        OpenStruct.new({
                         name: 'club',
                         data: {
                           type: 'successful_monthly_payment',
                           subscription_id: person_payment.subscription.id,
                           integration_id: person_payment.integration_id,
                           currency: person_payment.currency,
                           platform: person_payment.platform,
                           amount: person_payment.formatted_amount,
                           status: person_payment.status,
                           offer_id: person_payment.offer_id,
                           paid_date: person_payment.created_at.strftime('%d/%m/%Y')
                         }
                       })
      end
    end
  end
end
