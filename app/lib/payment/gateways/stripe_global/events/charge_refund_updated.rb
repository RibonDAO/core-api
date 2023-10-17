module Payment
  module Gateways
    module StripeGlobal
      module Events
        class ChargeRefundUpdated
          class << self
            def handle(event)
              external_id = event.data.object['payment_intent']

              update_status(external_id, 'refund_failed') if external_id
            end

            private

            def update_status(external_id, status)
              PersonPayment.where(external_id:).last&.update(status:)
            end
          end
        end
      end
    end
  end
end
