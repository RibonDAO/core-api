# frozen_string_literal: true

# replaced by the batch

module Donations
  class CreateBlockchainDonation < ApplicationCommand
    prepend SimpleCommand

    attr_reader :donation

    CENTS_FACTOR = 0.01

    def initialize(donation:)
      @donation = donation
    end

    def call
      transaction_hash = create_blockchain_donation
      create_donation_blockchain_transaction(transaction_hash)
    end

    private

    def create_blockchain_donation
      amount = ticket_value * CENTS_FACTOR
      non_profit_wallet_address = non_profit.wallet_address
      integration_wallet_address = integration.wallet_address

      ribon_contract.donate_through_integration(donation_pool:,
                                                non_profit_wallet_address:,
                                                integration_wallet_address:,
                                                donation_batch: user_hash(user&.email), amount:)
    end

    def create_donation_blockchain_transaction(transaction_hash)
      donation.create_donation_blockchain_transaction(transaction_hash:, chain:)
    end

    def sender_key
      @sender_key ||= integration.integration_wallet&.private_key
    end

    def ticket_value
      @ticket_value ||= RibonConfig.default_ticket_value
    end

    def ribon_contract
      @ribon_contract ||= Web3::Contracts::RibonContract.new(chain:)
    end

    def chain
      @chain ||= Chain.default
    end

    def non_profit
      @non_profit ||= donation.non_profit
    end

    def integration
      @integration ||= donation.integration
    end

    def user
      @user ||= donation.user
    end

    def donation_pool
      non_profit.cause&.default_pool || chain.default_donation_pool
    end

    def user_hash(email)
      Web3::Utils::Converter.keccak(email) if email
    end
  end
end
