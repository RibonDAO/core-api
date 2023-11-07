# frozen_string_literal: true

module Givings
  module Payment
    class CreditCardRefund < ApplicationCommand
      prepend SimpleCommand

      attr_reader :external_id

      def initialize(args)
        @external_id = args[:external_id]
      end

      def call
        if person_payment&.external_id?
          refund = Service::Givings::Payment::Orchestrator.new(payload: refund_params).call
        end
        success_refund(person_payment, refund)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
        errors.add(:message, e.message)
      end

      private

      def success_refund(person_payment, refund)
        return unless refund[:status] == 'succeeded'

        person_payment.update(status: :refunded,
                              refund_date: Time.zone.at(refund[:created]))
      end

      def person_payment
        PersonPayment.find_by({ external_id: })
      end

      def gateway
        person_payment.offer.gateway
      end

      def refund_params
        PaymentIntent.from(external_id, gateway, 'refund')
      end
    end
  end
end
