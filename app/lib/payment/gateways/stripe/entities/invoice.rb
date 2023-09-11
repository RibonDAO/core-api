module Payment
  module Gateways
    module Stripe
      module Entities
        class Invoice
          def self.find(id:)
            ::Stripe::Invoice.retrieve(id)
          end

          def self.upcoming(customer:)
            ::Stripe::Invoice.upcoming({ customer: })
          end
        end
      end
    end
  end
end
