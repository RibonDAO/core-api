require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Entities::Customer do
  describe '#create' do
    subject(:customer_creation_call) do
      described_class.create(customer:,
                             payment_method:)
    end

    let(:customer) { create(:customer) }
    let(:payment_method) { OpenStruct.new({ id: 'pay_123' }) }
    let(:method_parameters) do
      {
        email: customer.email,
        name: customer.name,
        payment_method: payment_method.id,
        invoice_settings: {
          default_payment_method: payment_method.id
        }
      }
    end

    before do
      allow(::Stripe::Customer).to receive(:create)
    end

    it 'calls the Stripe::Customer with correct params' do
      customer_creation_call

      expect(::Stripe::Customer)
        .to have_received(:create)
        .with(method_parameters)
    end
  end
end
