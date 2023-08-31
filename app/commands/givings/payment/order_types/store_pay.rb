# frozen_string_literal: true

module Givings
  module Payment
    module OrderTypes
      class StorePay
        attr_reader :payment_method_id, :email, :tax_id, :offer, :user, :payment_method,
                    :operation, :integration_id, :cause, :non_profit, :name

        def initialize(args)
          @payment_method_id = args[:payment_method_id]
          @email          = args[:email]
          @tax_id         = args[:tax_id]
          @offer          = args[:offer]
          @user           = args[:user]
          @operation      = args[:operation]
          @integration_id = args[:integration_id]
          @cause          = args[:cause]
          @non_profit     = args[:non_profit]
          @name           = args[:name]
          @payment_method = args[:payment_method_type]
        end

        def generate_order
          customer = find_or_create_customer
          subscription = create_subscription(customer) if operation == :subscribe
          payment = create_payment(customer, subscription)

          Order.from(payment, nil, operation, payment_method_id)
        end

        def process_payment(order)
          Service::Givings::Payment::Orchestrator.new(payload: order).call
        end

        def success_callback(order, _result)
          if non_profit
            call_add_non_profit_giving_blockchain_job(order)
          else
            call_add_cause_giving_blockchain_job(order)
          end
        end

        private

        def find_or_create_customer
          customer = Customer.find_by(user_id: user.id)
          if customer
            customer.update!(tax_id:)
            customer
          else
            Customer.create!(email:, tax_id:, name:, user:)
          end
        end

        def create_subscription(payer)
          Subscription.create!({ payer:, offer:, payment_method:, receiver:, status: :active, integration: })
        end

        def create_payment(payer, subscription)
          PersonPayment.create!({ payer:, offer:, paid_date:, integration:, payment_method:,
                                  amount_cents:, status: :processing, receiver:, subscription: })
        end

        def call_add_cause_giving_blockchain_job(order)
          AddGivingCauseToBlockchainJob.perform_later(amount: order.payment.crypto_amount,
                                                      payment: order.payment,
                                                      pool: cause&.default_pool)
        end

        def call_add_non_profit_giving_blockchain_job(order)
          AddGivingNonProfitToBlockchainJob.perform_later(non_profit:,
                                                          amount: order.payment.crypto_amount,
                                                          payment: order.payment)
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
