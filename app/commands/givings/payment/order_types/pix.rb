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

          Order.from(payment, nil, operation)
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
          Customer.find_by(user_id: user.id) || Customer.create!(email:, tax_id:, name:, user:)
        end

        def create_payment(payer)
          PersonPayment.create!({ payer:, offer:, paid_date:, integration:, payment_method:,
                                  amount_cents:, status: :processing, receiver:, platform: })
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
