module Payment
  module Gateways
    module StripeGlobal
      module Entities
        class Invoice
          def self.find(id:)
            ::Stripe::Invoice.retrieve(id)
          end
        end
      end
    end
  end
end
