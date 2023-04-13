# frozen_string_literal: true

module Service
  module Contributions
    class ContributionFeeCreatorService
      attr_reader :contribution_balance, :fee_cents, :contribution_increased_amount_cents, :contribution

      def initialize(contribution_balance:, fee_cents:,
                     contribution_increased_amount_cents:, contribution:)
        @contribution_balance = contribution_balance
        @fee_cents = fee_cents
        @contribution_increased_amount_cents = contribution_increased_amount_cents
        @contribution = contribution
      end

      def handle_fee_creation
        create_contribution_fee
        update_contribution_balance
      end

      private

      def update_contribution_balance
        ::Contributions::UpdateContributionBalance.call(contribution_balance:, fee_cents:,
                                                        contribution_increased_amount_cents:)
      end

      def create_contribution_fee
        ContributionFee.create!(contribution:, fee_cents:,
                                payer_contribution: contribution_balance.contribution,
                                payer_contribution_increased_amount_cents: contribution_increased_amount_cents)
      end
    end
  end
end
