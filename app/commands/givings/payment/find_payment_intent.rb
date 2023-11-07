# frozen_string_literal: true

module Givings
  module Payment
    class FindPaymentIntent < ApplicationCommand
      prepend SimpleCommand

      attr_reader :external_id

      def initialize(args)
        @external_id = args[:external_id]
      end

      def call
        if person_payment&.external_id?
          refund = Service::Givings::Payment::Orchestrator.new(payload: Refund.from(external_id, gateway,
                                                                                    'verify_payment_intent')).call
        end
        refund
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
        errors.add(:message, e.message)
      end

      private

      def person_payment
        PersonPayment.find_by({ external_id: })
      end

      def gateway
        person_payment.offer.gateway
      end
    end
  end
end
