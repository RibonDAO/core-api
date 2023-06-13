# frozen_string_literal: true

module PersonPayments
  module BlockchainTransactions
    class UpdateProcessingTransactions < ApplicationCommand
      prepend SimpleCommand

      def call
        PersonBlockchainTransaction.processing.find_each do |blockchain_transaction|
          update_status(blockchain_transaction)
        end
      end

      private

      def update_status(person_blockchain_transaction)
        PersonPaymentServices::BlockchainTransaction.new(person_blockchain_transaction:).update_status
      rescue StandardError => e
        Reporter.log(error: e)
      end
    end
  end
end
