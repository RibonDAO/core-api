module Payment
  module Gateways
    module Stripe
      module Billing
        class CardErrors < StandardError
          attr_reader :stripe_error

          def initialize(stripe_error)
            super
            @stripe_error = stripe_error
          end

          def external_id
            stripe_error[:external_id]
          end

          def code
            stripe_error[:code]
          end

          def message
            stripe_error[:message]
          end

          def error
            stripe_error[:outcome]
          end
        end
      end
    end
  end
end
