# frozen_string_literal: true

module Givings
  module Payment
    class GeneratePix < ApplicationCommand
      prepend SimpleCommand

      attr_reader :external_id

      def initialize(args)
        @external_id = args[:external_id]
      end

      def call
        if person_payment&.external_id?
          payment = Service::Givings::Payment::Orchestrator.new(payload: PaymentIntent.from(external_id, gateway,
                                                                                           'generate_pix')).call
        end
        payment
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
