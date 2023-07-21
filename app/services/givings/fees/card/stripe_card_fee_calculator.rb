module Givings
  module Fees
    module Card
      class StripeCardFeeCalculator
        attr_reader :value, :currency

        STRIPE_PERCENTAGE_FEE = 0.0399

        def initialize(value:, currency:)
          @value = Money.from_amount(value, currency)
          @currency = currency
        end

        def calculate_fee
          Currency::Rates.new(from: :brl, to: currency).add_rate unless currency == :brl

          ((value * STRIPE_PERCENTAGE_FEE) + stripe_fixed_fee).round
        end

        private

        def stripe_fixed_fee
          Money.from_cents(39, :brl)
        end
      end
    end
  end
end
