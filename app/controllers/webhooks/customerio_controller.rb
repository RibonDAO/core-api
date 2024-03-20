module Webhooks
  class CustomerioController < ApplicationController
    def events
      payload = request.body.read
      return head :forbidden unless valid_signature?(payload)

      handle_event(JSON.parse(payload, object_class: OpenStruct))

      head :ok
    rescue JSON::ParserError
      head :unprocessable_entity
    end

    private

    def valid_signature?(payload)
      Crm::Customer::WebhookSignatureValidator.new(
        endpoint_secret,
        request.headers['X-Cio-Signature'],
        request.headers['X-Cio-Timestamp'],
        payload
      ).validate
    end

    def endpoint_secret
      ENV.fetch('CUSTOMERIO_WEBHOOK_SECRET', nil)
    end

    def handle_event(event)
      case event.object_type
      when 'email'
        handle_email_event(event)
      else
        Rails.logger.info { "Unhandled event type: #{event.object_type}" }
      end
      nil
    end

    def handle_email_event(event)
      case event.metric
      when 'unsubscribed', 'dropped', 'spammed', 'failed'
        Users::UnsubscribeFromEmails.call(email: event.data.recipient)
      else
        Rails.logger.info { "Unhandled email event: #{event.metric}" }
      end
      nil
    end
  end
end
