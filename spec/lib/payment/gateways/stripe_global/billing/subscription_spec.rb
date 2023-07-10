require 'rails_helper'

RSpec.describe Payment::Gateways::StripeGlobal::Billing::Subscription do
  describe '#create' do
    subject(:method_call) { described_class.create(stripe_customer:, offer:) }

    let!(:price_cents) { 100 }

    let(:offer) { create(:offer, price_cents:, subscription: true) }
    let(:stripe_customer) { OpenStruct.new({ id: 'cus_123' }) }

    before do
      allow(::Stripe::Subscription).to receive(:create)
    end

    it 'calls the Stripe::Subscription with correct params' do
      method_call

      expect(::Stripe::Subscription)
        .to have_received(:create)
        .with(customer: stripe_customer.id,
              items: [
                price: offer.external_id
              ])
    end
  end

  describe '#cancel' do
    subject(:method_call) { described_class.cancel(subscription:) }

    let(:subscription) { OpenStruct.new({ external_identifier: 'sub_1JgyE4JuOnwQq9QxTbs7qfzm' }) }

    before do
      allow(::Stripe::Subscription).to receive(:delete)
    end

    it 'calls the Stripe::Subscription with correct params' do
      method_call

      expect(::Stripe::Subscription)
        .to have_received(:delete)
        .with(subscription.external_identifier)
    end
  end
end
