module Events
  module Donations
    class SendDonationEventJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      def perform(donation:)
        EventServices::SendEvent.new(user: donation.user, event: build_event(donation)).call
      end

      private

      def build_event(donation)
        OpenStruct.new({
                         name: 'donated',
                         data: {
                           integration_id: donation.integration_id,
                           non_profit_id: donation.non_profit_id,
                           user_id: donation.user_id,
                           platform: donation.platform,
                           value: donation.value,
                           created_at: donation.created_at,
                           total_number_of_donations: donation.user.donations.count,
                           donation_impact: impact_normalizer(donation.non_profit),
                           language: donation.user.language
                         }
                       })
      end

      def impact_normalizer(non_profit)
        Impact::Normalizer.new(
          non_profit,
          non_profit.impact_by_ticket
        ).normalize.join(' ')
      end
    end
  end
end
