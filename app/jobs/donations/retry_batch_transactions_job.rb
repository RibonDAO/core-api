module Donations
  class RetryBatchTransactionsJob < ApplicationJob
    queue_as :batches

    def perform
      BlockchainTransactions::UpdateProcessingTransactions.call
      BlockchainTransactions::UpdateFailedTransactions.call
      BlockchainTransactions::UpdateApiOnlyTransactions.call
    end
  end
end
