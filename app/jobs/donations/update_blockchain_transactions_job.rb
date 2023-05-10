module Donations
  class UpdateBlockchainTransactionsJob < ApplicationJob
    queue_as :default

    def perform
      BlockchainTransactions::UpdateProcessingTransactions.call
    end
  end
end
