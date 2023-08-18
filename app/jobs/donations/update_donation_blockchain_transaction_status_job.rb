module Donations
  class UpdateDonationBlockchainTransactionStatusJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(donation_blockchain_transaction)
      DonationServices::DonationBlockchainTransaction.new(donation_blockchain_transaction:).update_status
    end
  end
end
