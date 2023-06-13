module PersonPayments
  class RetryBlockchainTransactionsJob < ApplicationJob
    queue_as :default

    def perform
      BlockchainTransactions::UpdateProcessingTransactions.call
      BlockchainTransactions::UpdateFailedTransactions.call
      BlockchainTransactions::UpdateApiOnlyTransactions.call
    end
  end
end
