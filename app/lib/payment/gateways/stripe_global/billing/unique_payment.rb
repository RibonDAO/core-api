module Payment
  module Gateways
    module StripeGlobal
      module Billing
        class UniquePayment
          def self.create(stripe_customer:, stripe_payment_method:, offer:)
            ::Stripe::PaymentIntent.create({
                                             amount: offer.price_cents,
                                             currency: offer.currency,
                                             payment_method: stripe_payment_method,
                                             customer: stripe_customer,
                                             confirm: true
                                           })
          rescue ::Stripe::CardError => e
            charge = ::Stripe::Charge.retrieve(e.error.payment_intent.latest_charge)
            raise Stripe::CardErrors.new(
              external_id: charge.payment_intent,
              code: e.code,
              message: e.message,
              outcome: charge.outcome
            )
          end
        end
      end
    end
  end
end
