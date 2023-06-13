# frozen_string_literal: true

module Givings
  module CommunityTreasure
    class AddBalance < ApplicationCommand
      prepend SimpleCommand
      attr_reader :amount, :chain, :pool, :feeable

      def initialize(amount:, chain: default_chain, feeable: true, pool: nil)
        @amount = amount
        @chain = chain
        @pool = pool
        @feeable = feeable
      end

      def call
        ribon_contract.add_pool_balance(donation_pool:, amount:, feeable:)
      end

      private

      def default_chain
        @default_chain ||= Chain.default
      end

      def donation_pool
        pool || default_chain.default_donation_pool
      end

      def ribon_contract
        @ribon_contract ||= Web3::Contracts::RibonContract.new(chain:)
      end
    end
  end
end
