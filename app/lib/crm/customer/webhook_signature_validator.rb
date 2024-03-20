# Useful links:
# https://customer.io/docs/journeys/webhooks/#securely-verify-requests

module Crm
  module Customer
    class WebhookSignatureValidator
      def initialize(webhook_signing_secret, xcio_signature, xcio_timestamp, request_body)
        @webhook_signing_secret = webhook_signing_secret
        @xcio_signature = xcio_signature
        @xcio_timestamp = xcio_timestamp
        @request_body = request_body
      end

      def validate
        return false unless valid_headers? && valid_secret?

        signature = [@xcio_signature].pack('H*')
        mac = OpenSSL::HMAC.new(@webhook_signing_secret, OpenSSL::Digest.new('SHA256'))
        mac << "v0:#{@xcio_timestamp}:"
        mac << @request_body

        computed = mac.digest

        computed == signature
      rescue StandardError => e
        Rails.logger.error "Error validating signature: #{e}"
        false
      end

      private

      def valid_headers?
        Rails.logger.error 'Missing X-Cio-Signature header' if @xcio_signature.blank?
        Rails.logger.error 'Missing X-Cio-Timestamp header' if @xcio_timestamp.blank?

        @xcio_signature.present? && @xcio_timestamp.present?
      end

      def valid_secret?
        Rails.logger.error 'Missing Customer.IO webhook signing secret' if @webhook_signing_secret.blank?

        @webhook_signing_secret.present?
      end
    end
  end
end
