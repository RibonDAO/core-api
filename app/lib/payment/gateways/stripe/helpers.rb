module Payment
  module Gateways
    module Stripe
      class Helpers
        def self.status(stripe_status)
          case stripe_status
          when 'requires_action'
            :requires_action
          when 'requires_confirmation'
            :requires_confirmation
          when 'processing'
            :processing
          when 'canceled'
            :failed
          else
            :paid
          end
        end

        # rubocop:disable Metrics/AbcSize
        def self.raise_card_error(stripe_error)
          if stripe_error.error.charge
            charge = Entities::Charge.find(id: stripe_error.error.charge)
            external_id = charge.payment_intent
            type = charge.outcome.type
          else
            external_id = stripe_error.error.request_log_url
            type = stripe_error.error.type
          end

          raise Stripe::CardErrors.new(
            external_id:,
            code: stripe_error.error.code,
            message: stripe_error.error.message,
            type:
          )
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
