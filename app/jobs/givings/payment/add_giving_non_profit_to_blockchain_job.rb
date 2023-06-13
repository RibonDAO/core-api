module Givings
  module Payment
    class AddGivingNonProfitToBlockchainJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      def perform(non_profit:, amount:, payment:)
        transaction_hash = call_add_balance_command(non_profit, amount)
        payment.create_person_blockchain_transaction(treasure_entry_status: :processing, transaction_hash:)
      end

      private

      def call_add_balance_command(non_profit, amount)
        NonProfitTreasure::AddBalance.call(non_profit:, amount:).result
      end
    end
  end
end
