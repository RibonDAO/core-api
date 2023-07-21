module Givings
  module Fees
    module Card
      class StripeGlobalCardFeeCalculator
        attr_reader :value, :currency

        STRIPE_PERCENTAGE_FEE = 0.0299

        def initialize(value:, currency:)
          @value = Money.from_amount(value, currency)
          @currency = currency
        end

        def calculate_fee
          Currency::Rates.new(from: :usd, to: currency).add_rate unless currency == :usd

          ((value * STRIPE_PERCENTAGE_FEE) + stripe_fixed_fee).round
        end

        private

        def stripe_fixed_fee
          Money.from_cents(30, :usd)
        end
      end
    end
  end
end
