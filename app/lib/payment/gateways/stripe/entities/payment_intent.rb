module Payment
  module Gateways
    module Stripe
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
