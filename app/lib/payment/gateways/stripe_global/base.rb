module Payment
  module Gateways
    module StripeGlobal
      class Base
        ALLOWED_PAYMENT_METHODS = {
          card: 'card'
        }.freeze

        def initialize
          ::Stripe.api_key = RibonCoreApi.config[:stripe_global][:secret_key]
        end
      end
    end
  end
end
