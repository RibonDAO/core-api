module Service
  module Contributions
    class RemainingContributionFeeHandlerService
      attr_reader :contribution, :initial_contributions_balance, :remaining_fee

      CONTRACT_FEE_PERCENTAGE = 0.1

      def initialize(contribution:)
        @contribution = contribution
        @remaining_fee = remaining_fee
        @initial_contributions_balance = ContributionBalance.sum(:tickets_balance_cents)
      end

      def spread_remaining_fee
        return if not_enough_tickets_balance?

        create_fees_for_feeable_contributions
      end

      private

      def not_enough_tickets_balance?
        feeable_contribution_balances.empty?
      end

      def create_fees_for_feeable_contributions
        accumulated_fees_result = remaining_fee.ceil

        feeable_contribution_balances.each do |contribution_balance|
          if last_payer?(accumulated_fees_result:, contribution_balance:)
            handle_last_contribution_fee(accumulated_fees_result:, contribution_balance:)
            break 0
          end

          fee_cents, contribution_increased_amount_cents = fee_and_increased_value_for(contribution_balance:)
          handle_fee_creation_for(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)

          accumulated_fees_result -= fee_cents
        end
      end

      def handle_fee_creation_for(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)
        ContributionFeeCreatorService.new(contribution_balance:, fee_cents:, contribution:,
                                          contribution_increased_amount_cents:).handle_fee_creation
      end

      def last_payer?(accumulated_fees_result:, contribution_balance:)
        accumulated_fees_result < minimum_fee || contribution_balance == feeable_contribution_balances.last
      end

      def minimum_fee
        RibonConfig.minimum_contribution_chargeable_fee_cents
      end

      def feeable_contribution_balances
        @feeable_contribution_balances ||= ContributionQueries.new(contribution:)
                                                              .ordered_feeable_tickets_contribution_balances
      end

      def fee_and_increased_value_for(contribution_balance:)
        payer_balance = contribution_balance.tickets_balance_cents
        fee_to_be_paid = remaining_fee

        ContributionFeeCalculatorService
          .new(payer_balance:, fee_to_be_paid:, initial_contributions_balance:)
          .fee_and_increased_value_for(contribution:)
      end

      def handle_last_contribution_fee(accumulated_fees_result:, contribution_balance:)
        LastContributionFeeHandlerService
          .new(accumulated_fees_result:, contribution_balance:, contribution:)
          .charge_remaining_fee
      end
    end
  end
end
