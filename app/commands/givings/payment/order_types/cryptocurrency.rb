# frozen_string_literal: true

module Givings
  module Payment
    module OrderTypes
      class Cryptocurrency
        attr_reader :wallet_address, :payment_method, :user, :amount, :transaction_hash, :integration_id, :cause,
                    :non_profit

        def initialize(args)
          @wallet_address   = args[:wallet_address]
          @payment_method   = args[:payment_method]
          @user             = args[:user]
          @amount           = args[:amount]
          @transaction_hash = args[:transaction_hash]
          @integration_id   = args[:integration_id]
          @cause = args[:cause]
          @non_profit = args[:non_profit]
        end

        def generate_order
          crypto_user = find_or_create_crypto_user
          payment = create_payment(crypto_user)
          create_blockchain_transaction(payment)

          Order.from(payment)
        end

        def process_payment(order)
          {
            payer: order&.payer&.id,
            payment: order&.payment&.id,
            hash: transaction_hash
          }
        end

        def success_callback(_order, _result); end

        private

        def find_or_create_crypto_user
          CryptoUser.find_by(wallet_address:) || CryptoUser.create!(wallet_address:)
        end

        def create_payment(payer)
          PersonPayment.create!({ payer:, paid_date:, integration:,
                                  payment_method:, amount_cents:, status: :processing, receiver: })
        end

        def create_blockchain_transaction(payment)
          PersonBlockchainTransaction.create!(person_payment: payment, treasure_entry_status: :processing,
                                              transaction_hash:)
        end

        def amount_cents
          amount.to_f * 100
        end

        def paid_date
          Time.zone.now
        end

        def integration
          Integration.find_by_id_or_unique_address(integration_id)
        end

        def receiver
          non_profit || cause
        end
      end
    end
  end
end
