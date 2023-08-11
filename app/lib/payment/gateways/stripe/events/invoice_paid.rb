module Payment
  module Gateways
    module Stripe
      module Events
        class InvoicePaid
          class << self
            def handle(event)
              data = event.data.object
              subscription = Subscription.find_by(external_id: data['subscription'])
              return unless subscription

              external_id = data['id']

              payment = PersonPayment.find_or_create_by!(subscription:, external_id:)
              return unless payment
              return unless payment.status == 'requires_confirmation'

              payment.update(person_payment_params(subscription, data))
              handle_contribution_creation(payment)
              handle_giving_to_blockchain(payment)
            end

            private

            def person_payment_params(subscription, data)
              {
                paid_date: Time.zone.at(data['created']),
                amount_cents: data['amount_paid'],
                payment_method: subscription.payment_method,
                offer: subscription.offer,
                receiver: subscription.receiver,
                payer: subscription.payer,
                platform: subscription.platform,
                integration_id: subscription.integration_id || 1,
                status: :paid
              }
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
          end
        end
      end
    end
  end
end
