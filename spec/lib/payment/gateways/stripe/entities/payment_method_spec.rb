require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Entities::PaymentMethod do
  describe '#create' do
    subject(:payment_method_creation_call) do
      described_class.create(card:)
    end

    let(:gateway) { Payment::Gateways::Stripe::Base }

    let(:card) do
      Payment::Methods::Card.new(
        cvv: '117',
        name: 'User Test',
        number: '5434338600663578',
        expiration_month: '02',
        expiration_year: '24'
      )
    end

    let(:method_parameters) do
      {
        type: gateway::ALLOWED_PAYMENT_METHODS[:card],
        card: {
          number: card.number,
          exp_month: card.expiration_month,
          exp_year: card.expiration_year,
          cvc: card.cvv
        }
      }
    end

    before do
      allow(::Stripe::PaymentMethod).to receive(:create)
    end

    it 'calls the Stripe::PaymentMethod with correct params' do
      payment_method_creation_call

      expect(::Stripe::PaymentMethod)
        .to have_received(:create)
        .with(method_parameters)
    end
  end
end
