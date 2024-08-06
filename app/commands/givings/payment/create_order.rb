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

        RecursiveOpenStruct.new(payment_process_result.merge({ payment: order.payment }))
      rescue StandardError => e
        if e.message == I18n.t('subscriptions.already_exists')
          add_errors(e, e.message)
        else
          failure_callback(order, e)
          add_errors(e, I18n.t('person_payments.failed'))
        end
      end

      private

      def success_callback(order, result)
        return unless result

        status = ::Payment::Gateways::Stripe::Helpers.status(result[:status])
        update_success(order:, status:, result:)
        return unless status == :paid

        handle_contribution_creation(order.payment)
        klass.success_callback(order, result)
      end

      def add_errors(error, message)
        Reporter.log(error:, extra: { message: error.message }, level: :fatal)
        errors.add(:message, message)
      end

      def failure_callback(order, err)
        status = case err.type
                 when 'requires_action'
                   :requires_action
                 when 'blocked'
                   :blocked
                 else
                   :failed
                 end
        update_failed(order:, err:, status:)
      end

      def update_success(order:, status:, result:)
        if status == :paid
          ::Subscriptions::UpdateSubscriptionAttributeJob.perform_later(order.payment&.subscription,
                                                                        { status: :active })
        end
        ::PersonPayments::UpdatePaymentAttributeJob.perform_later(order.payment, { status: })
        update_external_ids(order:, result:)
      end

      def update_failed(order:, err:, status:)
        ::PersonPayments::UpdatePaymentAttributeJob.perform_later(order.payment, { status:, error_code: err.code })
        ::Subscriptions::UpdateSubscriptionAttributeJob.perform_later(order.payment&.subscription,
                                                                      { status: :payment_failed })
        if err.subscription_id
          ::Subscriptions::UpdateSubscriptionAttributeJob.perform_later(order.payment&.subscription,
                                                                        { external_id: err.subscription_id })
        end
        return unless err.external_id

        ::PersonPayments::UpdatePaymentAttributeJob.perform_later(order.payment,
                                                                  { external_id: err.external_id })
      end

      def handle_contribution_creation(payment)
        PersonPayments::CreateContributionJob.perform_later(payment)
      end

      def update_external_ids(order:, result:)
        external_id = result[:external_id]
        external_subscription_id = result[:external_subscription_id]
        external_invoice_id = result[:external_invoice_id]

        ::PersonPayments::UpdatePaymentAttributeJob.perform_later(order.payment, { external_id: }) if external_id
        if external_invoice_id
          ::PersonPayments::UpdatePaymentAttributeJob.perform_later(order.payment,
                                                                    { external_invoice_id: })
        end
        return unless external_subscription_id

        ::Subscriptions::UpdateSubscriptionAttributeJob.perform_later(order.payment&.subscription,
                                                                      { external_id: external_subscription_id })
      end
    end
  end
end
