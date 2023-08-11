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
      RibonCoreApi.config[:stripe_global][:endpoint_secret]
    end

    # TODO: Refactor this method to use a event handler factory for each event
    def event_handler(event)
      result = event.data.object
      external_id = result['payment_intent']
      case event.type
      when 'payment_intent.succeeded'
        ::Payment::Gateways::Stripe::Events::PaymentIntentSucceeded.handle(event)
      when 'charge.refunded'
        update_status(external_id, 'refunded') if external_id
        update_date(external_id, Time.zone.at(result[:created])) if external_id
      when 'charge.refund.updated'
        update_status(external_id, 'refund_failed') if external_id
      else
        Rails.logger.info { "Unhandled event type: #{event.type}" }
      end
      nil
    end

    def update_status(external_id, status)
      PersonPayment.where(external_id:).last&.update(status:)
    end

    def update_date(external_id, refund_date)
      PersonPayment.where(external_id:).last&.update(refund_date:)
    end
  end
end
