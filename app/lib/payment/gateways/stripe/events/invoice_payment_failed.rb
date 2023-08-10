module Payment
  module Gateways
    module Stripe
      module Events
        class InvoicePaymentFailed
          class << self
            def handle(event)
              data = event.data.object
              subscription = Subscription.find_by(external_id: data['subscription'])
              return unless subscription

              subscription.update(status: :inactive)
              PersonPayment.find_or_create_by!(person_payment_params(subscription, data))
            end

            private

            def person_payment_params(subscription, data)
              {
                external_id: data['external_id'],
                paid_date: Time.zone.at(data['created']),
                amount_cents: data['amount_paid'],
                payment_method: subscription.payment_method,
                offer: subscription.offer,
                receiver: subscription.receiver,
                subscription:,
                payer: subscription.payer,
                platform: subscription.platform,
                integration_id: subscription.integration_id || 1,
                status: :failed
              }
            end
          end
        end
      end
    end
  end
end
