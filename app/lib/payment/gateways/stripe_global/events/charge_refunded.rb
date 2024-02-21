module Payment
  module Gateways
    module StripeGlobal
      module Events
        class ChargeRefunded
          class << self
            attr_reader :person_payment

            def handle(event)
              external_id = event.data.object['payment_intent']
              created = event.data.object['created']

              @person_payment = PersonPayment.where(external_id:).last
              return unless person_payment&.status != 'refunded'

              update_person_payment(Time.zone.at(created))
            end

            private

            def update_person_payment(refund_date)
              person_payment&.update(status: :refunded, refund_date:)
              return unless person_payment&.subscription

              command = ::Givings::Subscriptions::CancelSubscription.call(
                subscription_id: person_payment.subscription.id
              )
              person_payment.subscription.update(status: :canceled, cancel_date: Time.zone.now) if command.success?
            end
          end
        end
      end
    end
  end
end
