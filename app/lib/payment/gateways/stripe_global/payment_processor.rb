module Payment
  module Gateways
    module StripeGlobal
      class PaymentProcessor < Base
        attr_reader :stripe_customer, :stripe_payment_method

        def purchase(order)
          setup_customer(order)
          payment = Billing::UniquePayment.create(stripe_customer:,
                                                  stripe_payment_method:, offer: order&.offer)

          {
            external_customer_id: stripe_customer.id,
            external_payment_method_id: stripe_payment_method.id,
            external_id: payment&.id,
            status: payment&.status,
            client_secret: payment&.client_secret
          }
        end

        # rubocop:disable Metrics/MethodLength
        # rubocop:disable Metrics/AbcSize
        def subscribe(order)
          setup_customer(order)
          subscription = Billing::Subscription.create(stripe_customer:, offer: order&.offer)
          invoice = Entities::Invoice.find(id: subscription.latest_invoice)
          payment_intent = Entities::PaymentIntent.find(id: invoice.payment_intent)
          if payment_intent.status == 'paid'
            {
              external_customer_id: stripe_customer.id,
              external_payment_method_id: stripe_payment_method.id,
              external_subscription_id: subscription.id,
              external_invoice_id: subscription.latest_invoice,
              external_id: payment_intent.id
            }
          else
            charge = ::Stripe::Charge.retrieve(payment_intent.latest_charge)
            raise Stripe::CardErrors.new(
              external_id: charge.payment_intent,
              code: e.code,
              message: e.message,
              outcome: charge.outcome
            )
          end
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize

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
          order_payer = order&.payer
          @stripe_payment_method = payment_method_by_order(order)
          @stripe_customer       = Entities::Customer.create(customer: order_payer,
                                                             payment_method: @stripe_payment_method)

          order_payer&.update(customer_keys: { stripe: @stripe_customer.id })
        end

        def payment_method_by_order(order)
          return Entities::PaymentMethod.find(id: order&.payment_method_id) if order&.payment_method_id

          Entities::PaymentMethod.create(card: order&.card)
        end
      end
    end
  end
end
