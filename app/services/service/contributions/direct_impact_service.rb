module Service
  module Contributions
    class DirectImpactService
      attr_reader :contribution

      def initialize(contribution:)
        @contribution = contribution
      end

      def impact
        contribution.non_profits.filter_map { |non_profit| direct_impact_for(non_profit) }
      end

      def direct_impact_for(non_profit)
        value = value_for(non_profit) / 100.0
        return unless value.positive?

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
        Money.from_amount(value, :currency).format
      end

      def value_for(non_profit)
        DonationContribution.joins(donation: :non_profit)
                            .where(contribution:)
                            .where(non_profits: { id: non_profit.id })
                            .sum(:value)
      end

      def currency
        contribution.person_payment.currency
      end
    end
  end
end
