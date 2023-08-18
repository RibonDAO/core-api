module GivingServiceservices
  module Impact
    class NonProfitImpactCalculator
      attr_reader :non_profit, :value, :currency

      def initialize(non_profit:, value:, currency:)
        @non_profit = non_profit
        @value = value
        @currency = currency
      end

      def rounded_impact
        @rounded_impact ||= impact.round
      end

      def impact
        @impact ||= (amount / usd_cents_to_one_impact).round(2)
      end

      def formatted_impact
        ::Impact::Normalizer.new(non_profit, rounded_impact).normalize
      rescue Exceptions::ImpactNormalizationError
        ['', '', '']
      end

      private

      def usd_cents_to_one_impact
        @usd_cents_to_one_impact ||= Money.from_cents(non_profit.impact_for.usd_cents_to_one_impact_unit, :usd)
      end

      def amount
        @amount ||= Currency::Converters.convert_to_usd(value:, from: currency)
      end
    end
  end
end
