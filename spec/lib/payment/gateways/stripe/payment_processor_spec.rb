require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::PaymentProcessor do
  let(:payment_processor_call) { described_class.new.send(operation, payload) }

  include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

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
                                     latest_invoice: 'in_1LL5lOJuOnwQq9QxgwtucIBS' }))
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

    let(:payload) { PaymentIntent.from(payment.external_id, gateway, operation) }
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
      allow(Stripe::Subscription).to receive(:retrieve).and_return(OpenStruct.new({ status: 'active' }))
    end

    it 'calls Stripe::Subscription api' do
      payment_processor_call

      expect(Stripe::Subscription)
        .to have_received(:cancel)
        .with(payload.external_identifier)
    end
  end

  describe '#generate_pix' do
    let(:operation) { :generate_pix }
    let(:gateway) { :stripe }

    let(:payload) { PaymentIntent.from(payment.external_id, gateway, operation) }
    let(:payment) { build(:person_payment, payment_method: :pix, offer:, external_id: 'pi_3JVG0oJuOnwQq9Qx118cDmEr') }
    let(:offer) { create(:offer, price_cents: 100, subscription: false) }

    before do
      allow(Stripe::PaymentIntent)
        .to receive(:confirm)
    end

    it 'calls Stripe::PaymentIntent api' do
      payment_processor_call

      expect(Stripe::PaymentIntent)
        .to have_received(:confirm).with(
          payment.external_id
        )
    end
  end

    describe '#find_payment_intent' do
    let(:operation) { :find_payment_intent }
    let(:gateway) { :stripe }

    let(:payload) { PaymentIntent.from(payment.external_id, gateway, operation) }
    let(:payment) { build(:person_payment, payment_method: :pix, offer:, external_id: 'in_1LL5lOJuOnwQq9QxgwtucIBS') }
    let(:offer) { create(:offer, price_cents: 100, subscription: false) }

    before do
      allow(Stripe::PaymentIntent)
        .to receive(:retrieve)
    end

    it 'calls Stripe::PaymentIntent api' do
      payment_processor_call

      expect(Stripe::PaymentIntent)
        .to have_received(:retrieve).with(
          payment.external_id
        )
    end
  end
end
