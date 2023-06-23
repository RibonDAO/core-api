module PersonPayments
  class RetryBlockchainTransactionsJob < ApplicationJob
    queue_as :default

    def perform
      BlockchainTransactions::Cause::UpdateProcessingTransactions.call
      BlockchainTransactions::Cause::UpdateFailedTransactions.call
      BlockchainTransactions::Cause::UpdateApiOnlyTransactions.call
      BlockchainTransactions::NonProfit::UpdateFailedTransactions.call
    end
  end
end
