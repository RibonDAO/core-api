module GivingServices
  module Fees
    module Crypto
      class PolygonFeeCalculator
        attr_reader :currency

        def initialize(currency:, value: nil)
          @currency = currency
          @value = value
        end

        def calculate_fee
          request = Request::ApiRequest.get(polygon_fee_url, expires_in: 2.hours)
          gas_fee_in_usd = request['speeds'].first['estimatedFee']

          formatted_gas_fee(gas_fee_in_usd).round
        end

        private

        def polygon_fee_url
          RibonCoreApi.config[:crypto_api][:polygon_gas_fee_url]
        end

        def formatted_gas_fee(gas_fee_in_usd)
          Currency::Converters.convert(from: :usd, to: currency, value: gas_fee_in_usd)
        end
      end
    end
  end
end
