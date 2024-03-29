module PersonPayments
  class RetryBlockchainTransactionsJob < ApplicationJob
    queue_as :person_payments

    def perform
      BlockchainTransactions::UpdateProcessingTransactions.call
      BlockchainTransactions::Cause::UpdateFailedTransactions.call
      BlockchainTransactions::Cause::UpdateApiOnlyTransactions.call
      BlockchainTransactions::NonProfit::UpdateFailedTransactions.call
    end
  end
end
