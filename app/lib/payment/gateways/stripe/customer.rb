module Payment
  module Gateways
    module Stripe
      class Customer < Base
        def create(order)
          order_payer = order&.payer
          stripe_payment_method = payment_method_by_order(order)
          stripe_customer       = Entities::Customer.create(customer: order_payer,
                                                            payment_method: stripe_payment_method)

          order_payer&.update(customer_keys: { stripe: stripe_customer.id })

          Entities::TaxId.add_to_customer(stripe_customer:,
                                          tax_id: order_payer&.tax_id)
          { stripe_customer:,
            stripe_payment_method: }
        rescue ::Stripe::CardError => e
          Helpers.raise_card_error(e)
        end

        private

        def payment_method_by_order(order)
          return Entities::PaymentMethod.find(id: order&.payment_method_id) if order&.payment_method_id

          Entities::PaymentMethod.create(card: order&.card) if order&.card
        end
      end
    end
  end
end
