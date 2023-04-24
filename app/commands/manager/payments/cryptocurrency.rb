# frozen_string_literal: true

module Manager
  module Payments
    class Cryptocurrency < ApplicationCommand
      prepend SimpleCommand

      attr_reader :amount, :transaction_hash, :integration_id, :receiver, :payer

      def initialize(args)
        @amount = args[:amount]
        @transaction_hash = args[:transaction_hash]
        @receiver = args[:receiver]
        @payer = args[:payer]
        @integration_id = args[:integration_id]
      end

      def call
        with_exception_handle do
          payment = create_payment
          create_blockchain_transaction(payment)
        end
      end

      private

      def create_payment
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

      def payment_method
        :crypto
      end
    end
  end
end
