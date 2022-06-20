module Payment
  module Gateways
    module Stripe
      module Entities
        class PaymentMethod
          def self.create(card:)
            ::Stripe::PaymentMethod.create({
                                             type: Base::ALLOWED_PAYMENT_METHODS[:card],
                                             card: {
                                               number: card&.number,
                                               exp_month: card&.expiration_month,
                                               exp_year: card&.expiration_year,
                                               cvc: card&.cvv
                                             }
                                           })
          end
        end
      end
    end
  end
end
