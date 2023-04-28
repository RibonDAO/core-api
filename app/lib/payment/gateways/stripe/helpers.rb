module Payment
  module Gateways
    module Stripe
      class Helpers
        def self.status(stripe_status)
          case stripe_status
          when 'requires_action'
            :requires_action
          when 'processing'
            :processing
          when 'canceled'
            :failed
          else
            :paid
          end
        end
      end
    end
  end
end
