module Webhooks
  class AlchemyController < ApplicationController
    def events
      payload = request.body.read
      return head :forbidden unless valid_signature?(payload)

      event_handler(JSON.parse(payload))
    end

    private

    def event_handler(payload)
      event_type = payload['type']
      transaction_hash = payload['event']['transaction']['hash'] if payload['event']['transaction']
      case event_type
      when 'DROPPED_TRANSACTION'
        update_status(transaction_hash, :dropped) if transaction_hash
      else
        Rails.logger.info { "Unhandled event type: #{event_type}" }
      end
      nil
    end

    def update_status(transaction_hash, status)
      blockchain_transaction = BlockchainTransaction.where(transaction_hash:).last
      return blockchain_transaction.update(status:) if blockchain_transaction

      PersonBlockchainTransaction.where(transaction_hash:).last&.update(treasure_entry_status: status)
    end

    def valid_signature?(payload)
      signature = request.headers['X-Alchemy-Signature']
      signing_key = RibonCoreApi.config[:alchemy][:webhook_signing_key]
      digest = OpenSSL::HMAC.hexdigest 'SHA256', signing_key, payload
      signature == digest
    end
  end
end
