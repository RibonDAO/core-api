module Givings
  module Payment
    module OrderTypes
      class FalsePayment
        attr_reader :email, :offer, :name, :user, :payment_method, :integration_id

        def initialize(args)
          @name = args[:name]
          @payment_method = :direct_transfer
          @email = args[:email]
          @offer = args[:offer]
          @integration_id = args[:integration_id]
        end

        def call
          @user = find_or_create_user
          customer = find_or_create_customer
          subscription = find_or_create_subscription(customer)
          payment = create_payment(customer, subscription)
        end

        def find_or_create_user
          user = User.find_by(email: :email)
          return user if user
          User.create(email: :email, language: I18n.locale)
        end

        def find_or_create_customer
          customer = Customer.find_by(user_id: user.id)
          return customer if customer
          Customer.create!(email:, name:, user:)
        end

        def find_or_create_subscription(payer)
          subscription = Subscription.find_by(payer:, offer:, payment_method:)
          return subscription if subscription
          Subscription.create!({ payer:, offer:, payment_method:, integration: })
        end

        def create_payment(payer, subscription)
          PersonPayment.create!({ payer:, offer:, paid_date:, payment_method:,
                                  amount_cents:, status: :paid, subscription:, integration: })
        end

        def integration
          Integration.find_by_id_or_unique_address(integration_id)
        end

        def paid_date
          Time.zone.now
        end

        def amount_cents
          offer.price_cents
        end
      end
    end
  end
end

