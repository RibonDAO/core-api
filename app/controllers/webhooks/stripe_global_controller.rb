module Webhooks
  class StripeGlobalController < ApplicationController
    def events
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
      return unless event

      event_handler(event)
    rescue JSON::ParserError
      head :unprocessable_entity
    rescue Stripe::SignatureVerificationError
      head :forbidden
    end

    private

    def endpoint_secret
      RibonCoreApi.config[:stripe_global][:endpoint_secret]
    end

    def event_handler(event)
      case event.type
      when 'payment_intent.succeeded'
        ::Payment::Gateways::StripeGlobal::Events::PaymentIntentSucceeded.handle(event)
      when 'invoice.paid'
        ::Payment::Gateways::StripeGlobal::Events::InvoicePaid.new.handle(event)
      when 'invoice.payment_failed'
        ::Payment::Gateways::StripeGlobal::Events::InvoicePaymentFailed.handle(event)
      when 'charge.refunded'
        ::Payment::Gateways::StripeGlobal::Events::ChargeRefunded.handle(event)
      when 'charge.refund.updated'
        ::Payment::Gateways::StripeGlobal::Events::ChargeRefundUpdated.handle(event)
      else
        Rails.logger.info { "Unhandled event type: #{event.type}" }
      end
      nil
    end
  end
end
