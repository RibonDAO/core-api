module Payment
  module Gateways
    module StripeGlobal
      module Entities
        class PaymentIntent
          def self.find(id:)
            ::Stripe::PaymentIntent.retrieve(id)
          end
        end
      end
    end
  end
end
