# frozen_string_literal: true

module Givings
  module Card
    class CalculateCardGiving < ApplicationCommand
      prepend SimpleCommand
      include GivingServices::Fees

      attr_reader :currency, :value, :gateway

      def initialize(value:, currency:, gateway: default_gateway)
        @value = value
        @currency = currency
        @gateway = gateway
      end

      def call
        with_exception_handle do
          net_giving = money_value - service_fees
          crypto_giving = converted_giving(net_giving)

          formatted_result(net_giving, crypto_giving)
        end
      end

      private

      def formatted_result(net_giving, crypto_giving)
        {
          giving_total: money_value, net_giving:, crypto_giving:,
          card_fee:, crypto_fee:, service_fees:
        }
      end

      def card_fee
        card_fee_calculator.calculate_fee
      end

      def crypto_fee
        crypto_fee_calculator.calculate_fee
      end

      def service_fees
        card_fee + crypto_fee
      end

      def card_fee_calculator
        FeeCalculator.new(value:, currency:, kind: gateway)
      end

      def crypto_fee_calculator
        FeeCalculator.new(value:, currency:, kind: :polygon)
      end

      def money_value
        @money_value ||= Money.from_amount(value, currency)
      end

      def converted_giving(net_giving)
        return net_giving if currency.to_sym.downcase == :usd

        Currency::Converters
          .convert(value: net_giving.amount, from: net_giving.currency.to_sym.downcase, to: :usd)
      end

      def default_gateway
        :stripe
      end
    end
  end
end
