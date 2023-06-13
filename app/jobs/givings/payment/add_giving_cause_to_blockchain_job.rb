module Givings
  module Payment
    class AddGivingCauseToBlockchainJob < ApplicationJob
      queue_as :default
      sidekiq_options retry: 3

      def perform(amount:, payment:, feeable: true, pool: nil)
        transaction_hash = call_add_balance_command(amount, feeable, pool)
        payment.create_person_blockchain_transaction(treasure_entry_status: :processing, transaction_hash:)
      end

      private

      def call_add_balance_command(amount, feeable, pool)
        CommunityTreasure::AddBalance.call(amount:, feeable:, pool:).result
      end
    end
  end
end
