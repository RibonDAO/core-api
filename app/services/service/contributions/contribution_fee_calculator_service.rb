# frozen_string_literal: true

module Service
  module Contributions
    class ContributionFeeCalculatorService
      attr_reader :payer_balance, :initial_contributions_balance, :fee_to_be_paid

      def initialize(payer_balance:, fee_to_be_paid:, initial_contributions_balance:)
        @payer_balance = payer_balance
        @fee_to_be_paid = fee_to_be_paid
        @initial_contributions_balance = initial_contributions_balance
      end

      def fee_and_increased_value_for(contribution:)
        [proportional_fee, increased_value_for(contribution:)]
      end

      def proportional_fee
        return payer_balance if payer_balance <= minimum_fee || payer_balance <= proportional_contribution

        [proportional_contribution, minimum_fee].max&.ceil
      end

      def increased_value_for(contribution:)
        contribution.usd_value_cents * paid_proportional_fee(contribution:)
      end

      private

      def minimum_fee
        @minimum_fee ||= RibonConfig.minimum_contribution_chargeable_fee_cents
      end

      def proportional_contribution
        fee_to_be_paid * payer_relative_percentage_of_total
      end

      def payer_relative_percentage_of_total
        @payer_relative_percentage_of_total ||= payer_balance / initial_contributions_balance.to_f
      end

      def paid_proportional_fee(contribution:)
        proportional_fee / contribution.generated_fee_cents.to_f
      end
    end
  end
end
