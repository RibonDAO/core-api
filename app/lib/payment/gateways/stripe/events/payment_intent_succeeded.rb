module Payment
  module Gateways
    module Stripe
      module Events
        class PaymentIntentSucceeded
          class << self
            def handle(event)
              payment = PersonPayment.where(external_id: event.data.object['id']).last
              return unless payment
              return unless payment.status == 'requires_confirmation'

              update_payment_status(payment)
              handle_contribution_creation(payment)
              handle_giving_to_blockchain(payment)

              handle_pix_subscription(payment)
            end

            private

            def update_payment_status(payment)
              payment.update(status: 'paid', paid_date: Time.zone.now)
            end

            def handle_giving_to_blockchain(payment)
              return if payment.person_blockchain_transaction&.success?

              return call_add_cause_giving_blockchain_job(payment) if payment.receiver_type == 'Cause'

              call_add_non_profit_giving_blockchain_job(payment)
            end

            def handle_contribution_creation(payment)
              return if payment.contribution.present?

              PersonPayments::CreateContributionJob.perform_later(payment)
            end

            def call_add_cause_giving_blockchain_job(payment)
              Givings::Payment::AddGivingCauseToBlockchainJob
                .perform_later(amount: payment.crypto_amount, payment:,
                               pool: payment.receiver&.default_pool)
            end

            def call_add_non_profit_giving_blockchain_job(payment)
              Givings::Payment::AddGivingNonProfitToBlockchainJob
                .perform_later(non_profit: payment.receiver,
                               amount: payment.crypto_amount, payment:)
            end

            def handle_pix_subscription(payment)
              subscription = existing_subscription(payment)
              return unless subscription

              activate_subscription(subscription)
              schedule_revoke_subscription_after_a_month(subscription)
            end

            def existing_subscription(payment)
              Subscription.find_by(payer: payment.payer, offer: payment.offer,
                                   payment_method: payment.payment_method)
            end

            def activate_subscription(subscription)
              subscription.update!(status: :active)
            end

            def schedule_revoke_subscription_after_a_month(subscription)
              Subscriptions::RevokeSubscriptionJob.set(wait: 1.month).perform_later(subscription)
            end
          end
        end
      end
    end
  end
end
