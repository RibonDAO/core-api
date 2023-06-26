# frozen_string_literal: true

module PersonPayments
  module BlockchainTransactions
    module NonProfit
      class UpdateFailedTransactions < ApplicationCommand
        prepend SimpleCommand

        def call
          failed_transactions = PersonPayment.where(receiver_type: 'NonProfit',
                                                    payment_method: :credit_card,
                                                    status: :paid).filter_map do |person_payment|
            person_payment.person_blockchain_transaction if person_payment.person_blockchain_transaction&.retry?
          end
          failed_transactions.each do |person_blockchain_transaction|
            update_transaction(non_profit: person_blockchain_transaction.person_payment.receiver,
                               amount: person_blockchain_transaction.person_payment.crypto_amount,
                               payment: person_blockchain_transaction.person_payment)
          end
        end

        private

        def update_transaction(non_profit:, amount:, payment:)
          Givings::Payment::AddGivingNonProfitToBlockchainJob.perform_later(non_profit:, amount:, payment:)
        rescue StandardError => e
          Reporter.log(error: e)
        end
      end
    end
  end
end
