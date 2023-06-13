desc 'Fetch and update payment status from stripe'
namespace :payment do
  task fetch_status: :environment do
    payments = PersonPayment.where(status: :failed)
                .where("EXISTS (SELECT 1 FROM person_blockchain_transactions WHERE person_payment_id = person_payments.id)")
                .where("EXISTS (SELECT 1 FROM contributions WHERE person_payment_id = person_payments.id)")

    payments.each do |payment|
      stripe_payment = ::Stripe::PaymentIntent.retrieve(payment.external_id)
      status = Payment::Gateways::Stripe::Helpers.status(stripe_payment.status)
      payment.update(status:)
    end
  end
end