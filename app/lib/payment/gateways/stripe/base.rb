module Payment
  module Gateways
    module Stripe
      class Base
        ALLOWED_PAYMENT_METHODS = {
          card: 'card'
        }.freeze

        ALLOWED_TAXID_TYPES = {
          brazil: {
            cpf: 'br_cpf',
            cnpj: 'br_cnpj'
          }
        }.freeze

        def initialize
          ::Stripe.api_key = RibonCoreApi.config[:stripe][:secret_key]
        end
      end
    end
  end
end
