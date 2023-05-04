# frozen_string_literal: true

module Givings
  module Payment
    class CreateOrder < ApplicationCommand
      prepend SimpleCommand

      attr_reader :klass

      def initialize(klass, args)
        @klass = klass.new(args)
      end

      def call
        order = klass.generate_order

        payment_process_result = klass.process_payment(order)

        success_callback(order, payment_process_result)

        payment_process_result
      rescue StandardError => e
        failure_callback(order, payment_process_result, e)
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
        errors.add(:message, e.message)
      end

      private

      def success_callback(order, result)
        return unless result

        status = ::Payment::Gateways::Stripe::Helpers.status(result[:status])
        order.payment.update(status:)
        order.payment.update(external_id: result[:external_id]) if result[:external_id]
        return unless status == :paid

        handle_contribution_creation(order.payment)
        klass.success_callback(order, result)
      end

      def failure_callback(order, _result, error)
        order.payment.update(status: :failed, error_code: error.code)
      end

      def handle_contribution_creation(payment)
        Contributions::CreateContribution.call(payment:)
      end
    end
  end
end
