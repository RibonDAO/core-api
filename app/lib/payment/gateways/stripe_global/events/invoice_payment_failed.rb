module Payment
  module Gateways
    module StripeGlobal
      module Events
        class InvoicePaymentFailed
          class << self
            attr_reader :subscription, :payment, :data

            def handle(event)
              @data = event.data.object
              @subscription = Subscription.find_by(external_id: data['subscription'])
              return unless subscription

              subscription.update(status: :inactive)

              external_invoice_id = data['id']

              @payment = PersonPayment.where(subscription:, external_invoice_id:).first_or_initialize
              set_payment_attributes
              payment.save!
            end

            private

            # rubocop:disable Metrics/AbcSize
            def set_payment_attributes
              payment.paid_date = Time.zone.at(data['created'])
              payment.amount_cents = subscription.offer.price_cents
              payment.external_id = data['payment_intent']
              payment.payment_method = subscription.payment_method
              payment.offer = subscription.offer
              payment.receiver = receiver_person_payment
              payment.payer = subscription.payer
              payment.platform = subscription.platform
              payment.integration = subscription.integration
              payment.status = :failed
            end
            # rubocop:enable Metrics/AbcSize

            def receiver_person_payment
              return Cause.where(status: :active).sample if subscription.category == 'club'

              subscription.receiver
            end
          end
        end
      end
    end
  end
end
