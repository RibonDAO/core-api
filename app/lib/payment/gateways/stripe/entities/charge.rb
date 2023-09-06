module Payment
  module Gateways
    module Stripe
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
