module Payment
  module Gateways
    module StripeGlobal
      class PaymentProcessor < Base
        attr_reader :stripe_customer, :stripe_payment_method

        def purchase(order)
          setup_customer(order)
          payment = Billing::UniquePayment.create(stripe_customer:,
                                                  stripe_payment_method:, offer: order&.offer)

          purchase_success(payment)
        rescue ::Stripe::CardError => e
          Helpers.raise_card_error(e)
        end

        def subscribe(order)
          setup_customer(order)
          subscription = Billing::Subscription.create(stripe_customer:, offer: order&.offer)
          invoice = Entities::Invoice.find(id: subscription.latest_invoice)
          payment_intent = Entities::PaymentIntent.find(id: invoice.payment_intent)

          return subscribe_failed(payment_intent, subscription) unless payment_intent.status == 'succeeded'

          subscribe_success(payment_intent, subscription)
        end

        def unsubscribe(subscription_params)
          subscription = Billing::Subscription.find(id: subscription_params.external_identifier)
          if subscription[:status] == 'active'
            return Billing::Subscription.cancel(subscription: subscription_params)
          end

          subscription
        end

        def refund(payment)
          Billing::Refund.create(external_id: payment.external_id)
        end

        private

        def setup_customer(order)
          result = Customer.new.create(order)
          @stripe_customer = result[:stripe_customer]
          @stripe_payment_method = result[:stripe_payment_method]
        end

        def purchase_success(payment)
          {
            external_customer_id: stripe_customer&.id,
            external_payment_method_id: stripe_payment_method&.id,
            external_id: payment&.id,
            status: payment&.status,
            client_secret: payment&.client_secret
          }
        end

        def subscribe_success(payment_intent, subscription)
          {
            external_customer_id: stripe_customer.id,
            external_payment_method_id: stripe_payment_method.id,
            external_subscription_id: subscription.id,
            external_invoice_id: subscription.latest_invoice,
            external_id: payment_intent.id
          }
        end

        def payment_intent_from_subscription(subscription)
          invoice = Entities::Invoice.find(id: subscription.latest_invoice)
          Entities::PaymentIntent.find(id: invoice.payment_intent)
        end

        def subscribe_failed(payment_intent, subscription)
          charge = Entities::Charge.find(id: payment_intent.latest_charge)
          raise Stripe::CardErrors.new(
            external_id: charge.payment_intent,
            subscription_id: subscription.id,
            code: charge.failure_code,
            message: charge.failure_message
          )
        end
      end
    end
  end
end
