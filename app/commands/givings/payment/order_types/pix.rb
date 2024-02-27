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
          @payment_method = :pix
          @user           = args[:user]
          @operation      = args[:operation]
          @integration_id = args[:integration_id]
          @cause          = args[:cause]
          @non_profit     = args[:non_profit]
          @platform       = args[:platform]
        end

        def generate_order
          customer = find_or_create_customer
          subscription = create_subscription(customer) if offer.category == 'club'
          payment = create_payment(customer, subscription)

          Order.from_pix(payment)
        end

        def process_payment(order)
          Service::Givings::Payment::Orchestrator.new(payload: order).call
        end

        def success_callback
          return unless user_already_has_pix_subscription?

          return unless existing_subscription

          activate_subscription(existing_subscription)
          schedule_revoke_subscription_after_a_month(existing_subscription)
        end

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

        def create_payment(payer, subscription)
          PersonPayment.create!({ payer:, offer:, paid_date:, integration:, payment_method:,
                                  amount_cents:, status: :processing, receiver:, platform:, subscription: })
        end

        def create_subscription(payer)
          if user_already_has_pix_subscription? return
          else
            Subscription.create!({ payer:, offer:, payment_method:, status: :inactive, platform:,
                                   integration: })
          end
        end

        def user_already_has_pix_subscription?
          Subscription.exists?(payer:, offer:, payment_method:)
        end

        def existing_subscription
          Subscription.find_by(payer:, offer:, payment_method:)
        end

        def activate_subscription(subscription)
          subscription.update!(status: :active)
        end

        def schedule_revoke_subscription_after_a_month(subscription)
          Subscriptions::RevokeSubscriptionJob.set(wait: 1.month).perform_later(subscription)
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

        def random_cause
          Cause.order('RANDOM()').first
        end

        def receiver
          return random_cause if offer.category == 'club'

          non_profit || cause
        end
      end
    end
  end
end
