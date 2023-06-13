# frozen_string_literal: true

module Givings
  module NonProfitTreasure
    class AddBalance < ApplicationCommand
      prepend SimpleCommand
      attr_reader :amount, :chain, :non_profit

      def initialize(amount:, non_profit:, chain: default_chain)
        @amount = amount
        @chain = chain
        @non_profit = non_profit
      end

      def call
        ribon_contract.contribute_to_non_profit(non_profit_pool:, non_profit_wallet_address:, amount:)
      end

      private

      def default_chain
        @default_chain ||= Chain.default
      end

      def non_profit_wallet_address
        non_profit.wallet_address
      end

      def non_profit_pool
        non_profit.cause&.default_pool
      end

      def ribon_contract
        @ribon_contract ||= Web3::Contracts::RibonContract.new(chain:)
      end
    end
  end
end
