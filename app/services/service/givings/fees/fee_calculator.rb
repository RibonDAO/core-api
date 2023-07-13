module Service
  module Givings
    module Fees
      class FeeCalculator
        attr_reader :value, :kind, :currency

        def initialize(value:, kind:, currency:)
          @value = value
          @kind = kind
          @currency = currency
        end

        delegate :calculate_fee, to: :calculator_class_factory

        private

        def calculator_class_factory
          calculator_services[kind].new(value:, currency:)
        end

        def calculator_services
          {
            stripe: Card::StripeCardFeeCalculator,
            stripe_global: Card::StripeGlobalCardFeeCalculator,
            polygon: Crypto::PolygonFeeCalculator
          }
        end
      end
    end
  end
end
