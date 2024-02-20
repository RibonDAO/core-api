# frozen_string_literal: true

module Givings
  module Payment
    module OrderTypes
      class Pix
        attr_reader :email, :tax_id, :offer, :payment_method, :name,
                    :user, :operation, :integration_id, :cause, :non_profit, :platform

        def initialize(args)
          @email          = args[:email]
          @tax_id         = args[:tax_id]
          @name           = args[:name]
          @offer          = args[:offer]
          @payment_method = args[:payment_method]
          @user           = args[:user]
          @operation      = args[:operation]
          @integration_id = args[:integration_id]
          @cause          = args[:cause]
          @non_profit     = args[:non_profit]
          @platform       = args[:platform]
        end

        def generate_order
          customer = find_or_create_customer
          payment  = create_payment(customer)

          Order.from_pix(payment, operation)
        end

        def process_payment(order)
          Service::Givings::Payment::Orchestrator.new(payload: order).call
        end

        def success_callback; end

        private

        def find_or_create_customer
          customer = Customer.find_by(user_id: user.id)
          if customer
            customer.update!(tax_id:) if tax_id.present?
            customer
          else
            Customer.create!(email:, tax_id:, name:, user:)
          end
        end

        def create_payment(payer)
          PersonPayment.create!({ payer:, offer:, paid_date:, integration:, payment_method:,
                                  amount_cents:, status: :processing, receiver:, platform: })
        end

        def create_subscription(payer)
          return if user_already_has_pix_subscription?

          Subscription.create!({ payer:, offer:, payment_method:, status: :active, receiver:, platform:,
                                 integration: })
          schedule_revoke_subscription_after_a_month(subscription)
        end

        def user_already_has_pix_subscription?
          Subscription.exists?(payer:, offer:, payment_method:)
        end

        def schedule_revoke_subscription_after_a_month(subscription)
          #Service::Givings::Payment::Subscription::RevokeScheduler.new(subscription).call
        end

        def amount_cents
          offer.price_cents
        end

        def paid_date
          Time.zone.now
        end

        def integration
          Integration.find_by_id_or_unique_address(integration_id)
        end

        def receiver
          non_profit || cause
        end
      end
    end
  end
end
