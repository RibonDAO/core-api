# frozen_string_literal: true

module Donations
  class Donate < ApplicationCommand
    prepend SimpleCommand
    attr_reader :non_profit, :integration, :donation, :user, :transaction_hash

    CENTS_FACTOR = 0.01

    def initialize(integration:, non_profit:, user:)
      @integration = integration
      @non_profit = non_profit
      @user = user
    end

    def call
      with_exception_handle do
        Donation.transaction do
          create_donation
          @transaction_hash = create_blockchain_donation
          set_user_last_donation_at
          update_donation_blockchain_link(transaction_hash)
        end

        transaction_hash
      end
    end

    private

    def create_donation
      @donation = Donation.create!(
        integration:,
        non_profit:,
        user:,
        value: ticket_value
      )
    end

    def create_blockchain_donation
      amount = Web3::Utils::Converter.to_wei(ticket_value * CENTS_FACTOR)

      response = Web3::RibonContract.donate_through_integration(
        non_profit_address: non_profit.wallet_address,
        amount:,
        user_email: user.email
      )

      body = JSON.parse(response['body'])
      body['transactionHash']
    end

    def update_donation_blockchain_link(transaction_hash)
      donation.blockchain_process_link = "#{RibonCoreApi.config[:blockchain][:scan_url]}#{transaction_hash}"
      donation.save
    end

    def set_user_last_donation_at
      SetUserLastDonationAt.call(user:, date_to_set: donation.created_at)
    end

    def ticket_value
      RibonConfig.default_ticket_value
    end
  end
end
