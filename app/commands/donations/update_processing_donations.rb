# frozen_string_literal: true

# replaced by the batch

module Donations
  class UpdateProcessingDonations < ApplicationCommand
    prepend SimpleCommand

    def call
      DonationBlockchainTransaction.processing.find_each do |donation_blockchain_transaction|
        update_status(donation_blockchain_transaction)
      end
    end

    private

    def update_status(donation_blockchain_transaction)
      Service::Donations::DonationBlockchainTransaction.new(donation_blockchain_transaction:).update_status
    rescue StandardError => e
      Reporter.log(error: e)
    end
  end
end
