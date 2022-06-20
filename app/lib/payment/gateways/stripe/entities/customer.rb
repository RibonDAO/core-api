module Payment
  module Gateways
    module Stripe
      module Entities
        class Customer
          def self.create(customer:, payment_method:)
            ::Stripe::Customer.create({
                                        email: customer&.email,
                                        name: customer&.name,
                                        payment_method: payment_method.id,
                                        invoice_settings: {
                                          default_payment_method: payment_method.id
                                        }
                                      })
          end
        end
      end
    end
  end
end
