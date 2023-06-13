# frozen_string_literal: true

module Donations
  module BlockchainTransactions
    class UpdateFailedTransactions < ApplicationCommand
      prepend SimpleCommand

      def call
        failed_transactions = Batch.all.filter_map do |batch|
          batch.blockchain_transaction if batch.blockchain_transaction&.failed?
        end
        failed_transactions.each do |blockchain_transaction|
          batch = blockchain_transaction.owner
          non_profit = batch.non_profit
          integration = batch.integration
          update_transaction(non_profit, integration, batch)
        end
      end

      private

      def update_transaction(non_profit, integration, batch)
        CreateBatchBlockchainDonation.call(non_profit:, integration:, batch:)
      rescue StandardError => e
        Reporter.log(error: e)
      end
    end
  end
end
