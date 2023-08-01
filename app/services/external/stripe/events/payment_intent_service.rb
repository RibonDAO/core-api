module External
  module Stripe
    module Events
      class PaymentIntentService
        class << self
          def handle_payment_intent_succeeded(event)
            result = event.data.object
            external_id = result['id']
            payment = PersonPayment.where(external_id:).last

            return if payment&.status == 'paid'
            return unless payment

            payment.update(status: 'paid', paid_date: Time.zone.at(result[:created]))
            handle_contribution_creation(payment)
            add_giving_to_blockchain(payment)
          end

          private

          def add_giving_to_blockchain(payment)
            return call_add_cause_giving_blockchain_job(payment) if payment.receiver_type == 'Cause'

            call_add_non_profit_giving_blockchain_job(payment)
          end

          def handle_contribution_creation(payment)
            return if payment.contribution.present?

            PersonPayments::CreateContributionJob.perform_later(payment)
          end

          def call_add_cause_giving_blockchain_job(payment)
            Givings::Payment::AddGivingCauseToBlockchainJob.perform_later(amount: payment.crypto_amount, payment:,
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
