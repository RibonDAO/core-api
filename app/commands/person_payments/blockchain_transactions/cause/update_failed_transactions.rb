# frozen_string_literal: true

module PersonPayments
  module BlockchainTransactions
    module Cause
      class UpdateFailedTransactions < ApplicationCommand
        prepend SimpleCommand

        def call
          failed_transactions = valid_person_payments.filter_map do |person_payment|
            person_payment.person_blockchain_transaction if person_payment.person_blockchain_transaction&.retry?
          end
          failed_transactions.each do |person_blockchain_transaction|
            update_transaction(amount: person_blockchain_transaction.person_payment.crypto_amount,
                               payment: person_blockchain_transaction.person_payment,
                               pool: person_blockchain_transaction.person_payment.receiver&.default_pool)
          end
        end

        private

        def valid_person_payments
          PersonPayment.where(receiver_type: 'Cause', status: :paid).where.not(payment_method: :crypto)
        end

        def update_transaction(amount:, payment:, pool:)
          Givings::Payment::AddGivingCauseToBlockchainJob.perform_later(amount:, payment:, pool:)
        rescue StandardError => e
          Reporter.log(error: e)
        end
      end
    end
  end
end
