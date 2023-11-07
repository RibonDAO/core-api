module Payment
  module Gateways
    module Stripe
      class PaymentProcessor < Base
        attr_reader :stripe_customer, :stripe_payment_method

        def purchase(order)
          setup_customer(order)
          payment = Billing::UniquePayment.create(stripe_customer:, stripe_payment_method:, offer: order&.offer)

          purchase_success(payment)
        rescue ::Stripe::CardError => e
          Helpers.raise_card_error(e)
        end

        def create_intent(order)
          setup_customer(order)
          payment = Billing::Intent
                    .create(stripe_customer:, stripe_payment_method:, customer: stripe_customer,
                            offer: order&.offer, payment_method_types: order&.payment_method_types,
                            payment_method_data: order&.payment_method_data,
                            payment_method_options: order&.payment_method_options)

          purchase_success(payment)
        end

        def subscribe(order)
          setup_customer(order)
          subscription = Billing::Subscription.create(stripe_customer:, offer: order&.offer)
          invoice = Entities::Invoice.find(id: subscription.latest_invoice)
          payment_intent = Entities::PaymentIntent.find(id: invoice.payment_intent)

          return subscribe_incomplete(payment_intent, subscription.id) unless payment_intent.status == 'succeeded'

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

        def generate_pix(payment)
          Entities::PaymentIntent.confirm(id: payment.external_id)
        end

        def find_payment_intent(payment)
          Entities::PaymentIntent.find(id: payment.external_id)
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

        # rubocop:disable Metrics/MethodLength
        def subscribe_incomplete(payment_intent, subscription_id)
          code = payment_intent.status
          message = payment_intent.status
          type = payment_intent.status
          if payment_intent.latest_charge
            charge = Entities::Charge.find(id: payment_intent.latest_charge)
            code = charge.failure_code
            message = charge.failure_message
            type = charge.outcome&.type
          end
          raise Stripe::CardErrors.new(
            external_id: payment_intent.id,
            subscription_id:,
            code:,
            message:,
            type:
          )
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
