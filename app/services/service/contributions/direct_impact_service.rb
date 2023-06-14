module Service
  module Contributions
    class DirectImpactService
      attr_reader :contribution

      def initialize(contribution:)
        @contribution = contribution
      end

      def impact
        contribution.non_profits.map { |non_profit| direct_impact_for(non_profit) }
      end

      def direct_impact_for(non_profit)
        value = value_for(non_profit)

        {
          non_profit:,
          formatted_impact: formatted_impact_for(non_profit, value),
          total_amount_donated: formatted_amount_for(value)
        }
      end

      private

      def formatted_impact_for(non_profit, value)
        Service::Givings::Impact::NonProfitImpactCalculator
          .new(non_profit:, value:, currency: :usd).formatted_impact
      end

      def formatted_amount_for(value)
        Money.from_cents(value, :usd).format
      end

      def value_for(non_profit)
        DonationContribution.joins(donation: :non_profit)
                            .where(contribution:)
                            .where(non_profits: { id: non_profit.id })
                            .sum(:value)
      end

      def payment
        @payment ||= @contribution.person_payment
      end

      def balance
        @balance ||= @contribution.contribution_balance
      end

      def paid_fees
        @paid_fees ||= ContributionFee.where(payer_contribution: @contribution).sum(:fee_cents)
      end
    end
  end
end
