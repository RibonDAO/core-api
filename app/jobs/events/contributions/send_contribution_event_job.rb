module Events
  module Contributions
    class SendContributionEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      def perform(contribution:)
        EventServices::SendEvent.new(user: contribution.person_payment.payer.user,
                                     event: build_event(contribution)).call
      end

      private

      # rubocop:disable Metrics/MethodLength
      def build_event(contribution)
        person_payment = contribution.person_payment
        OpenStruct.new({
                         name: 'contributed',
                         data: {
                           contribution_id: contribution.id,
                           integration_id: person_payment.integration_id,
                           receiver_type: person_payment.receiver_type,
                           receiver_id: person_payment.receiver_id,
                           currency: person_payment.currency,
                           platform: person_payment.platform,
                           amount: person_payment.formatted_amount,
                           paid_date: person_payment.paid_date,
                           status: person_payment.status,
                           offer_id: person_payment.offer_id,
                           total_number_of_contributions: person_payment.payer.contributions.count
                         }
                       })
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
