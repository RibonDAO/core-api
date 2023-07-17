require 'rails_helper'

RSpec.describe Payment::Gateways::StripeGlobal::Billing::Refund do
  describe '#create' do
    subject(:method_call) { described_class.create(external_id:) }

    let(:payment) { build(:person_payment, payment_method: :credit_card, offer:, external_id: 'pi_123') }
    let(:offer) { create(:offer, price_cents: 100, subscription: false) }

    let(:external_id) { 'pi_123' }

    before do
      allow(::Stripe::Refund).to receive(:create)
    end

    it 'calls the Stripe::Refund with correct params' do
      method_call

      expect(::Stripe::Refund)
        .to have_received(:create)
        .with({ payment_intent: payment.external_id })
    end
  end
end
