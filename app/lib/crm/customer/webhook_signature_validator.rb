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
        signature = [@xcio_signature].pack('H*')
        mac = OpenSSL::HMAC.new(@webhook_signing_secret, OpenSSL::Digest.new('SHA256'))
        mac << "v0:#{@xcio_timestamp}:"
        mac << @request_body

        computed = mac.digest

        return computed

        computed == signature
      rescue StandardError
        false
      end
    end
  end
end
