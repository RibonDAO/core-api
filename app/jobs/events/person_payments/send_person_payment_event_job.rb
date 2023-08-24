module Events
  module PersonPayments
    class SendPersonPaymentEventJob < ApplicationJob
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

      # rubocop:disable Metrics/MethodLength
      def build_event(person_payment)
        OpenStruct.new({
                         name: 'subscribed',
                         data: {
                           contribution_id: person_payment.contribution_id,
                           integration_id: person_payment.integration_id,
                           receiver_type: person_payment.receiver_type,
                           receiver_id: person_payment.receiver_id,
                           currency: person_payment.currency,
                           platform: person_payment.platform,
                           amount: person_payment.formatted_amount,
                           paid_date: person_payment.paid_date.strftime('%d/%m/%Y'),
                           status: person_payment.status,
                           offer_id: person_payment.offer_id,
                           total_number_of_contributions: person_payment.payer.contributions.count,
                           receiver_name: person_payment.receiver.name
                         }
                       })
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
end
