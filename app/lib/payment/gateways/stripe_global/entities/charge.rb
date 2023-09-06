module Payment
  module Gateways
    module StripeGlobal
      module Entities
        class Charge
          def self.find(id:)
            ::Stripe::Charge.retrieve(id)
          end
        end
      end
    end
  end
end
