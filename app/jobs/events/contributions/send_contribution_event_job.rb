module Events
  module Contributions
    class SendContributionEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      def perform(person_payment:)
        EventServices::SendEvent.new(user: person_payment.payer.user, event: build_event(person_payment)).call
      end

      private

      def build_event(person_payment)
        OpenStruct.new({
                        name: 'contributed',
                        data: {
                          email: person_payment.payer.user.email,
                          integration_id: person_payment.integration_id,
                          receiver_type: person_payment.receiver_type,
                          receiver_id: person_payment.receiver_id,
                          currency: person_payment.currency,
                          platform: person_payment.platform,
                          amount: person_payment.formatted_amount,
                          paid_date: person_payment.paid_date,
                          status: person_payment.status,
                          offer_id: person_payment.offer_id,
                          created_at: person_payment.created_at,
                          language: person_payment.payer.user.language,
                          total_number_of_contributions: person_payment.payer.person_payments.count,
                        }
                       })
      end
    end
  end
end
