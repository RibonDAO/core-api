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

    def update_status(external_id, status)
      PersonPayment.where(external_id:).last&.update(status:)
    end

    def event_handler(event)
      result = event.data.object
      external_id = result['payment_intent']
      case event.type
      when 'charge.refunded'
        update_status(external_id, 'refunded') if external_id
      when 'charge.refund.updated'
        update_status(external_id, 'refund_failed') if external_id
      else
        Rails.logger.debug { "Unhandled event type: #{event.type}" }
      end
      nil
    end
  end
end
