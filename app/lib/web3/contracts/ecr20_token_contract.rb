module Web3
  module Contracts
    class Ecr20TokenContract < BaseContract
      attr_reader :token, :chain

      def initialize(chain:, token:)
        @chain = chain
        @token = token
      end

      def approve(spender:, amount:)
        transact('approve', spender, amount, sender_key: Providers::Keys::RIBON_KEY)
      end

      private

      def contract_name
        'Ecr20TokenContract'.freeze
      end

      def address
        (::Eth::Address.new token).address
      end

      def abi
        File.read("#{Rails.root}/app/lib/web3/utils/abis/ecr20_token_abi.json")
      end
    end
  end
end
