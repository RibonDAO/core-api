module Webhooks
  class StripeController < ApplicationController
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
      RibonCoreApi.config[:stripe][:endpoint_secret]
    end

    def event_handler(event)
      case event.type
      when 'payment_intent.succeeded'
        ::Payment::Gateways::Stripe::Events::PaymentIntentSucceeded.handle(event)
      when 'invoice.paid'
        ::Payment::Gateways::Stripe::Events::InvoicePaid.new.handle(event)
      when 'invoice.payment_failed'
        ::Payment::Gateways::Stripe::Events::InvoicePaymentFailed.handle(event)
      when 'charge.refunded'
        ::Payment::Gateways::Stripe::Events::ChargeRefunded.handle(event)
      when 'charge.refund.updated'
        ::Payment::Gateways::Stripe::Events::ChargeRefundUpdated.handle(event)
      else
        Rails.logger.info { "Unhandled event type: #{event.type}" }
      end
      nil
    end
  end
end
