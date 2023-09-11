require 'rails_helper'

RSpec.describe Payment::Gateways::StripeGlobal::Customer do
  let(:setup_customer) { described_class.new.create(order) }

  include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

  before do
    allow(Stripe::PaymentMethod).to receive(:create).and_return(OpenStruct.new({ id: 'pay_123' }))
    allow(Stripe::Customer).to receive(:create).and_return(OpenStruct.new({ id: 'cus_123' }))
  end

  describe '#create' do
    let(:operation) { :purchase }
    let(:order) { Order.from(payment, credit_card, operation) }
    let(:credit_card) { build(:credit_card) }
    let(:payer) { create(:customer) }
    let(:payment) { build(:person_payment, payment_method: :credit_card, offer:, payer:) }
    let(:offer) { create(:offer, price_cents: 100, subscription: true) }

    before do
      allow(Stripe::Customer).to receive(:create).and_return(OpenStruct.new({ id: 'cus_123' }))
    end

    it 'calls Stripe::Customer api' do
      setup_customer

      expect(Stripe::Customer)
        .to have_received(:create)
        .with(email: payer.email,
              name: payer.name,
              payment_method: 'pay_123',
              invoice_settings: { default_payment_method: 'pay_123' })
    end

    it 'returns a stripe_customer and a stripe_payment_method' do
      expect(setup_customer).to eq({ stripe_customer: OpenStruct.new({ id: 'cus_123' }),
                                     stripe_payment_method: OpenStruct.new({ id: 'pay_123' }) })
    end
  end
end
