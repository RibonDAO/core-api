module Payment
  module Gateways
    module StripeGlobal
      module Billing
        class Subscription
          def self.create(stripe_customer:, offer:)
            ::Stripe::Subscription.create(
              {
                customer: stripe_customer.id,
                items: [
                  { price: offer.external_id }
                ]
              }
            )
          end

          def self.cancel(subscription:)
            ::Stripe::Subscription.cancel(subscription.external_identifier)
          end
        end
      end
    end
  end
end
