module Service
  module Contributions
    class TicketLabelingService
      attr_reader :donation

      def initialize(donation:)
        @donation = donation
      end

      def label_donation
        payer_contribution = next_contribution_to_label_the_donation

        create_donation_contribution(contribution: payer_contribution)
        update_contribution_balance(contribution_balance: payer_contribution.contribution_balance)

        payer_contribution
      rescue StandardError => e
        Reporter.log(error: e)
      end

      private

      def create_donation_contribution(contribution:)
        DonationContribution.create!(contribution:, donation:)
      end

      def update_contribution_balance(contribution_balance:)
        contribution_balance.tickets_balance_cents -= donation.value
        contribution_balance.save!
      end

      def next_contribution_to_label_the_donation
        ::Contributions::Labeling::DetermineChosenContribution.call(donation:).result
      end
    end
  end
end
