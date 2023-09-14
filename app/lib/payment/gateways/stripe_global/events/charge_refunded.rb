module Payment
  module Gateways
    module StripeGlobal
      module Events
        class ChargeRefunded
          class << self
            def handle(event)
              external_id = event.data.object['payment_intent']
              created = event.data.object['created']

              update_status(external_id, 'refunded') if external_id
              update_date(external_id, Time.zone.at(created)) if external_id
            end

            private

            def update_status(external_id, status)
              PersonPayment.where(external_id:).last&.update(status:)
            end

            def update_date(external_id, refund_date)
              PersonPayment.where(external_id:).last&.update(refund_date:)
            end
          end
        end
      end
    end
  end
end
