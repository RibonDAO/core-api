module Payment
  module Gateways
    module Stripe
      module Entities
        class Customer
          def self.create(customer:, payment_method:, address: default_address)
            ::Stripe::Customer.create({
                                        email: customer&.email,
                                        name: customer&.name,
                                        payment_method: payment_method&.id,
                                        invoice_settings: {
                                          default_payment_method: payment_method&.id
                                        },
                                        address:
                                      })
          end

          def self.default_address
            {
              country: 'BR',
              city: 'Brasília',
              state: 'DF'
            }
          end
        end
      end
    end
  end
end
