require 'rails_helper'

RSpec.describe Payment::Gateways::StripeGlobal::Billing::UniquePayment do
  describe '#create' do
    subject(:method_call) do
      described_class.create(stripe_payment_method:,
                             stripe_customer:, offer:)
    end

    let!(:currency) { 'brl' }
    let!(:price_cents) { 100 }

    let(:offer) { create(:offer, price_cents:, subscription: false) }
    let(:stripe_customer) { instance_double(::Stripe::Customer) }
    let(:stripe_payment_method) { instance_double(::Stripe::PaymentMethod) }

    before do
      allow(::Stripe::PaymentIntent).to receive(:create)
    end

    it 'calls the Stripe::PaymentIntent with correct params' do
      method_call

      expect(::Stripe::PaymentIntent)
        .to have_received(:create)
        .with(payment_method: stripe_payment_method,
              customer: stripe_customer, amount: price_cents,
              currency:, confirm: true)
    end
  end
end
