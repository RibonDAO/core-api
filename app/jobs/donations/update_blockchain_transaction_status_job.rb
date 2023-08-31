module Donations
  class UpdateBlockchainTransactionStatusJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: 3

    def perform(blockchain_transaction)
      DonationServices::BlockchainTransaction.new(blockchain_transaction:).update_status
    end
  end
end
