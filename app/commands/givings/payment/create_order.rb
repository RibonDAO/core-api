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
        failure_callback(order, e)
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
        errors.add(:message, e.message)
      end

      private

      def success_callback(order, result)
        return unless result

        status = ::Payment::Gateways::Stripe::Helpers.status(result[:status])
        update_success(order:, status:, external_id: result[:external_id],
                       external_subscription_id: result[:external_subscription_id])
        return unless status == :paid

        handle_contribution_creation(order.payment)
        klass.success_callback(order, result)
      end

      def failure_callback(order, err)
        if err.error.type == 'blocked'
          update_blocked(order:, err:)
        else
          update_failed(order:, err:)
        end
      end

      def update_success(order:, status:, external_id:, external_subscription_id:)
        order.payment.update(status:)

        order.payment.update(external_id:) if external_id

        order.payment&.subscription&.update(external_id: external_subscription_id) if external_subscription_id
      end

      def update_blocked(order:, err:)
        order.payment.update(status: :blocked, error_code: err.code)
        order.payment.update(external_id: err.external_id) if err&.external_id
      end

      def update_failed(order:, err:)
        order.payment.update(status: :failed, error_code: err.code)
        order.payment&.subscription&.update(status: :inactive)
        order.payment.update(external_id: err.error.request_log_url) if err&.error&.request_log_url
      end

      def handle_contribution_creation(payment)
        PersonPayments::CreateContributionJob.perform_later(payment)
      end
    end
  end
end
