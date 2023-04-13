# frozen_string_literal: true

module Service
  module Contributions
    class LastContributionFeeHandlerService
      attr_reader :accumulated_fees_result, :contribution_balance, :contribution

      def initialize(accumulated_fees_result:, contribution_balance:, contribution:)
        @accumulated_fees_result = accumulated_fees_result
        @contribution_balance = contribution_balance
        @contribution = contribution
      end

      def charge_remaining_fee
        deal_with_remaining_fee

        fee_cents = [accumulated_fees_result, contribution_balance.fees_balance_cents].min
        contribution_increased_amount_cents =
          contribution.usd_value_cents * fee_cents / contribution.generated_fee_cents.to_f

        handle_fee_creation_for(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)
      end

      def deal_with_remaining_fee
        return if accumulated_fees_result <= contribution_balance.fees_balance_cents

        remaining_fee = accumulated_fees_result - contribution_balance.fees_balance_cents
        HandleRemainingContributionFee.new(contribution:, remaining_fee:).spread_remaining_fee
      end

      private

      def handle_fee_creation_for(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)
        ContributionFeeCreatorService.new(contribution_balance:, fee_cents:, contribution:,
                                          contribution_increased_amount_cents:).handle_fee_creation
      end
    end
  end
end
