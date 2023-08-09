# frozen_string_literal: true

module Donations
  class CreateBatchBlockchainDonation < ApplicationCommand
    prepend SimpleCommand

    attr_reader :non_profit, :integration, :batch

    CENTS_FACTOR = 0.01

    def initialize(non_profit:, integration:, batch:)
      @non_profit = non_profit
      @integration = integration
      @batch = batch
    end

    def call
      SleeperHelper.sleep(30)
      transaction_hash = create_blockchain_donation
      create_batch_blockchain_transaction(transaction_hash)
    end

    private

    def create_blockchain_donation
      amount = @batch.amount * CENTS_FACTOR
      non_profit_wallet_address = @non_profit.wallet_address
      integration_wallet_address = @integration.wallet_address

      ribon_contract.donate_through_integration(donation_pool:,
                                                non_profit_wallet_address:,
                                                integration_wallet_address:,
                                                donation_batch:, amount:)
    end

    def create_batch_blockchain_transaction(transaction_hash)
      @batch.create_batch_blockchain_transaction(transaction_hash:, chain:)
    end

    def ribon_contract
      @ribon_contract ||= Web3::Contracts::RibonContract.new(chain:)
    end

    def chain
      @chain ||= Chain.default
    end

    def donation_pool
      @non_profit.cause&.default_pool || chain.default_donation_pool
    end

    def donation_batch
      @batch.cid
    end
  end
end
