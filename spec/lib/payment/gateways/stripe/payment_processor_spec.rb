require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::PaymentProcessor do
  let(:payment_processor_call) { described_class.new.send(operation, payload) }

  before do
    allow(Stripe::PaymentMethod).to receive(:create).and_return(OpenStruct.new({ id: 'pay_123' }))
    allow(Stripe::Customer).to receive(:create).and_return(OpenStruct.new({ id: 'cus_123' }))
    allow(Stripe::Customer).to receive(:create_tax_id).and_return(OpenStruct.new({ id: 'tax_123' }))
  end

  describe '#purchase' do
    let(:operation) { :purchase }

    let(:payload) { Order.from(payment, credit_card, operation) }
    let(:credit_card) { build(:credit_card) }
    let(:payment) { build(:person_payment, payment_method: :credit_card, offer:) }
    let(:offer) { create(:offer, price_cents: 100, subscription: true) }

    before do
      allow(Stripe::PaymentIntent).to receive(:create)
    end

    it 'calls Stripe::PaymentIntent api' do
      payment_processor_call

      expect(Stripe::PaymentIntent)
        .to have_received(:create)
        .with(payment_method: OpenStruct.new({ id: 'pay_123' }),
              customer: OpenStruct.new({ id: 'cus_123' }), amount: 100,
              currency: 'brl', confirm: true)
    end
  end

  describe '#subscribe' do
    let(:operation) { :subscribe }

    let(:payload) { Order.from(payment, credit_card, operation) }
    let(:credit_card) { build(:credit_card) }
    let(:payment) { build(:person_payment, payment_method: :credit_card, offer:) }
    let(:offer) { create(:offer, price_cents: 100, subscription: true) }

    before do
      allow(Stripe::Subscription)
        .to receive(:create)
        .and_return(OpenStruct.new({ id: 'sub_123',
                                     latest_invoice: 'in_123' }))
    end

    it 'calls Stripe::Subscription api' do
      payment_processor_call

      expect(Stripe::Subscription)
        .to have_received(:create).with({
                                          customer: 'cus_123',
                                          items: [
                                            { price: offer.external_id }
                                          ]
                                        })
    end
  end

  describe '#refund' do
    let(:operation) { :refund }
    let(:gateway) { :stripe }

    let(:payload) { Refund.from(payment.external_id, gateway, operation) }
    let(:payment) { build(:person_payment, payment_method: :credit_card, offer:) }
    let(:offer) { create(:offer, price_cents: 100, subscription: false) }

    before do
      allow(Stripe::Refund)
        .to receive(:create)
    end

    it 'calls Stripe::Refund api' do
      payment_processor_call

      expect(Stripe::Refund)
        .to have_received(:create).with({
                                          payment_intent: payment.external_id
                                        })
    end
  end

  describe '#unsubscribe' do
    let(:operation) { :unsubscribe }

    let(:payload) { OpenStruct.new({ external_identifier: 'sub_123' }) }

    before do
      allow(Stripe::Subscription).to receive(:cancel)
    end

    it 'calls Stripe::Subscription api' do
      payment_processor_call

      expect(Stripe::Subscription)
        .to have_received(:cancel)
        .with(payload.external_identifier)
    end
  end
end
