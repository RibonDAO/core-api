# frozen_string_literal: true

module Donations
  module BlockchainTransactions
    class UpdateApiOnlyTransactions < ApplicationCommand
      prepend SimpleCommand

      def call
        batches_without_blockchain_transaction.each do |batch|
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

      def batches_without_blockchain_transaction
        batch_query = %(LEFT OUTER JOIN blockchain_transactions
                          ON blockchain_transactions.owner_id = batches.id
                          AND blockchain_transactions.owner_type = 'Batch'
                        )

        @batches_without_blockchain_transaction ||= Batch
                                                    .joins(batch_query)
                                                    .where(blockchain_transactions: { id: nil })
      end
    end
  end
end
