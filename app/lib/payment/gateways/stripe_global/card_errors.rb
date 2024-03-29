module Payment
  module Gateways
    module StripeGlobal
      class CardErrors < StandardError
        attr_reader :stripe_error

        def initialize(stripe_error)
          super
          @stripe_error = stripe_error
        end

        def external_id
          stripe_error[:external_id]
        end

        def subscription_id
          stripe_error[:subscription_id]
        end

        def code
          stripe_error[:code]
        end

        def message
          stripe_error[:message]
        end

        def type
          stripe_error[:type]
        end
      end
    end
  end
end
