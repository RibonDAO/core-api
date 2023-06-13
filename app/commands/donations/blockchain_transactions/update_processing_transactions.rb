# frozen_string_literal: true

module Donations
  module BlockchainTransactions
    class UpdateProcessingTransactions < ApplicationCommand
      prepend SimpleCommand

      def call
        BlockchainTransaction.processing.find_each do |blockchain_transaction|
          update_status(blockchain_transaction)
        end
      end

      private

      def update_status(blockchain_transaction)
        Service::Donations::BlockchainTransaction.new(blockchain_transaction:).update_status
      rescue StandardError => e
        Reporter.log(error: e)
      end
    end
  end
end
