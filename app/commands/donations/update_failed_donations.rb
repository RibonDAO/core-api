# frozen_string_literal: true

# replaced by the batch

module Donations
  class UpdateFailedDonations < ApplicationCommand
    prepend SimpleCommand

    def call
      failed_transactions = Donation.all.filter_map do |donation|
        donation.donation_blockchain_transaction if donation.donation_blockchain_transaction&.failed?
      end
      failed_transactions.each do |donation_blockchain_transaction|
        update_transaction(donation_blockchain_transaction.donation)
      end
    end

    private

    def update_transaction(donation)
      CreateBlockchainDonation.call(donation:)
    rescue StandardError => e
      Reporter.log(error: e)
    end
  end
end
