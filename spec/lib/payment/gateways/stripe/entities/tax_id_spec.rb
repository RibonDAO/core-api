require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Entities::TaxId do
  describe '#add_to_customer' do
    subject(:taxid_addition_call) do
      described_class.add_to_customer(stripe_customer:, tax_id:)
    end

    let(:gateway) { Payment::Gateways::Stripe::Base }

    let(:stripe_customer) { OpenStruct.new({ id: 'cus_123' }) }
    let(:tax_id) { '11122233345' }

    let(:method_parameters) do
      [
        stripe_customer.id,
        {
          type: gateway::ALLOWED_TAXID_TYPES[:brazil][:cpf],
          value: tax_id
        }
      ]
    end

    before do
      allow(::Stripe::Customer).to receive(:create_tax_id)
    end

    it 'calls the Stripe::PaymentMethod with correct params' do
      taxid_addition_call

      expect(::Stripe::Customer)
        .to have_received(:create_tax_id)
        .with(*method_parameters)
    end
  end
end
