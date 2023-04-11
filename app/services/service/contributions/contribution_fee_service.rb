module Service
  module Contributions
    class ContributionFeeService
      attr_reader :contribution, :initial_contributions_balance

      CONTRACT_FEE_PERCENTAGE = 0.1

      def initialize(contribution:)
        @contribution = contribution
        @initial_contributions_balance = ContributionBalance.sum(:fees_balance_cents)
      end

      def spread_fee_to_payers
        ordered_feeable_contribution_balances.reduce(initial_fee_generated_by_new_contribution.ceil) do
        |accumulated_fees_result, contribution_balance|
          if last_payer?(accumulated_fees_result:, contribution_balance:)
            charge_remaining_fee_from_last_contribution_balance(accumulated_fees_result:, contribution_balance:)
            break 0
          end

          fee_cents = calculate_fee_for(contribution_balance:)
          total_fees_increased_cents = calculate_increased_value_for(contribution_balance:)
          create_contribution_fee(contribution_balance:, fee_cents:)
          update_contribution_balance(contribution_balance:, fee_cents:, total_fees_increased_cents:)

          accumulated_fees_result - fee_cents
        end
      end

      private

      def last_payer?(accumulated_fees_result:, contribution_balance:)
        accumulated_fees_result < minimum_fee || contribution_balance == ordered_feeable_contribution_balances.last
      end

      def minimum_fee
        RibonConfig.minimum_contribution_chargeable_fee_cents
      end

      def initial_fee_generated_by_new_contribution
        contribution.usd_value_cents * CONTRACT_FEE_PERCENTAGE
      end

      def ordered_feeable_contribution_balances
        @ordered_feeable_contribution_balances ||= ContributionBalance.all
                                                                      .where.not(contribution_id: contribution.id)
                                                                      .order(:fees_balance_cents)
      end

      def calculate_fee_for(contribution_balance:)
        ContributionFeeCalculatorService
          .new(payer_contribution_balance: contribution_balance,
               fee_to_be_paid: initial_fee_generated_by_new_contribution,
               initial_contributions_balance:).calculate_proportional_fee
      end

      def calculate_increased_value_for(contribution_balance:)
        ContributionFeeCalculatorService
          .new(payer_contribution_balance: contribution_balance,
               fee_to_be_paid: initial_fee_generated_by_new_contribution,
               initial_contributions_balance:)
          .calculate_increased_value_for(contribution:)
      end

      def update_contribution_balance(contribution_balance:, fee_cents:, total_fees_increased_cents:)
        ::Contributions::UpdateContributionBalance.call(contribution_balance:, fee_cents:,
                                                        total_fees_increased_cents:)
      end

      def create_contribution_fee(contribution_balance:, fee_cents:)
        ContributionFee.create!(contribution:, fee_cents:, payer_contribution: contribution_balance.contribution)
      end

      def charge_remaining_fee_from_last_contribution_balance(accumulated_fees_result:, contribution_balance:)
        fee_cents = [accumulated_fees_result, contribution_balance.fees_balance_cents].min
        ContributionFee.create!(contribution:, fee_cents:, payer_contribution: contribution_balance.contribution)

        update_contribution_balance(contribution_balance:, fee_cents:, total_fees_increased_cents: fee_cents)
      end
    end
  end
end
