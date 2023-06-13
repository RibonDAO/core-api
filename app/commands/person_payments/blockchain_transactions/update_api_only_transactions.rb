# frozen_string_literal: true

module PersonPayments
  module BlockchainTransactions
    class UpdateApiOnlyTransactions < ApplicationCommand
      prepend SimpleCommand

      def call
        person_payments_without_blockchain_transaction.each do |person_payment|
          update_transaction(amount: person_payment.crypto_amount,
                             payment: person_payment,
                             pool: person_payment.receiver&.default_pool)
        end
      end

      private

      def update_transaction(amount:, payment:, pool:)
        Givings::Payment::AddGivingCauseToBlockchainJob.perform_later(amount:, payment:, pool:)
      rescue StandardError => e
        Reporter.log(error: e)
      end

      def person_payments_without_blockchain_transaction
        query = %(LEFT OUTER JOIN person_blockchain_transactions
                  ON person_blockchain_transactions.person_payment_id = person_payments.id)
        @person_payments_without_blockchain_transaction ||= PersonPayment
                                                            .where(receiver_type: 'Cause',
                                                                   payment_method: :credit_card,
                                                                   status: :paid)
                                                            .joins(query)
                                                            .where(person_blockchain_transactions: { id: nil })
      end
    end
  end
end
