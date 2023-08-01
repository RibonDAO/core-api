module Payment
  module Gateways
    module Stripe
      module Billing
        class Intent
          def self.create(options)
            ::Stripe::PaymentIntent.create({
                                             amount: options[:offer].price_cents,
                                             currency: options[:offer].currency,
                                             payment_method_types: options[:payment_method_types],
                                             payment_method_data: options[:payment_method_data],
                                             payment_method_options: options[:payment_method_options],
                                             customer: options[:stripe_customer],
                                             payment_method: options[:stripe_payment_method]
                                           })
          end
        end
      end
    end
  end
end
