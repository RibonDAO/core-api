module Web3
  module Utils
    class Gas
      DEFAULT_MAX_FEE_PER_GAS = 1_000
      DEFAULT_MAX_PRIORITY_FEE_PER_GAS = 300
      DEFAULT_GAS_LIMIT = 400_000

      attr_reader :chain

      def initialize(chain:)
        @chain = chain
      end

      def estimate_gas
        request = Request::ApiRequest.get("#{chain.gas_fee_url}?eip1559=true", expires_in: 2.hours)
        speeds = request['speeds'].second

        max_fee_per_gas = [speeds['maxFeePerGas'], DEFAULT_MAX_FEE_PER_GAS].min
        max_priority_fee_per_gas = [speeds['maxPriorityFeePerGas'], DEFAULT_MAX_PRIORITY_FEE_PER_GAS].min

        OpenStruct.new({ max_fee_per_gas:, max_priority_fee_per_gas:, default_gas_limit: DEFAULT_GAS_LIMIT })
      rescue StandardError
        OpenStruct.new({ max_fee_per_gas: DEFAULT_MAX_FEE_PER_GAS,
                         max_priority_fee_per_gas: DEFAULT_MAX_PRIORITY_FEE_PER_GAS,
                         default_gas_limit: DEFAULT_GAS_LIMIT })
      end
    end
  end
end
