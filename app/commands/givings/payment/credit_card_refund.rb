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
        payment = find_person_payment
        refund = Service::Givings::Payment::Orchestrator.new(payload: refund_params).call if payment&.external_id?
        success_refund(payment, refund)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
        errors.add(:message, e.message)
      end

      private

      def success_refund(payment, refund)
        if refund[:status] == 'succeeded'
          Rails.logger.debug Time.zone.at(refund[:created])
          payment.update(status: :refunded,
                         refund_date: Time.zone.at(refund[:created]))
        end
      end

      def find_person_payment
        PersonPayment.find_by({ external_id: })
      end

      def refund_params
        Refund.from(external_id, 'stripe', 'refund')
      end
    end
  end
end
