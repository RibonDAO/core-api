module Service
  module Contributions
    class HandleRemainingContributionFee
      attr_reader :contribution, :initial_contributions_balance, :remaining_fee

      CONTRACT_FEE_PERCENTAGE = 0.1

      def initialize(contribution:, remaining_fee:)
        @contribution = contribution
        @remaining_fee = remaining_fee
        @initial_contributions_balance = ContributionBalance.sum(:tickets_balance_cents)
      end

      def spread_remaining_fee
        ordered_feeable_contribution_balances.reduce(remaining_fee.ceil) do
        |accumulated_fees_result, contribution_balance|
          if last_payer?(accumulated_fees_result:, contribution_balance:)
            charge_remaining_fee_from_last_contribution_balance(accumulated_fees_result:, contribution_balance:)
            break 0
          end

          fee_cents = calculate_fee_for(contribution_balance:)
          contribution_increased_amount_cents = calculate_increased_value_for(contribution_balance:)
          create_contribution_fee(contribution_balance:, fee_cents:,
                                  payer_contribution_increased_amount_cents: contribution_increased_amount_cents)
          update_contribution_balance(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)

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

      def ordered_feeable_contribution_balances
        @ordered_feeable_contribution_balances ||= ContributionBalance
                                                   .with_tickets_balance
                                                   .with_paid_status
                                                   .where.not(contribution_id: contribution.id)
                                                   .order(tickets_balance_cents: :asc)
      end

      def calculate_fee_for(contribution_balance:)
        ContributionFeeCalculatorService
          .new(payer_balance: contribution_balance.tickets_balance_cents,
               fee_to_be_paid: remaining_fee,
               initial_contributions_balance:).proportional_fee
      end

      def calculate_increased_value_for(contribution_balance:)
        ContributionFeeCalculatorService
          .new(payer_balance: contribution_balance.tickets_balance_cents,
               fee_to_be_paid: remaining_fee,
               initial_contributions_balance:)
          .increased_value_for(contribution:)
      end

      def update_contribution_balance(contribution_balance:, fee_cents:, contribution_increased_amount_cents:)
        contribution_balance.contribution_increased_amount_cents += contribution_increased_amount_cents
        contribution_balance.tickets_balance_cents -= fee_cents
        contribution_balance.save
      end

      def create_contribution_fee(contribution_balance:, fee_cents:, payer_contribution_increased_amount_cents:)
        ContributionFee.create!(contribution:, fee_cents:, payer_contribution: contribution_balance.contribution,
                                payer_contribution_increased_amount_cents:)
      end

      def charge_remaining_fee_from_last_contribution_balance(accumulated_fees_result:, contribution_balance:)
        fee_cents = [accumulated_fees_result, contribution_balance.tickets_balance_cents].min
        payer_contribution_increased_amount_cents =
          contribution.usd_value_cents * fee_cents / contribution.generated_fee_cents.to_f

        create_contribution_fee(contribution_balance:, fee_cents:, payer_contribution_increased_amount_cents:)

        update_contribution_balance(contribution_balance:, fee_cents:,
                                    contribution_increased_amount_cents: fee_cents)
      end
    end
  end
end
