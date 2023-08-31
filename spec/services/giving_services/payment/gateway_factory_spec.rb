require 'rails_helper'

RSpec.describe GivingServices::Payment::GatewayFactory, type: :service do
  subject(:service_call) { described_class.new(gateway_symbol).call }

  describe '#call' do
    context 'when gateway is Stripe' do
      let(:gateway) { Payment::Gateways::Stripe }
      let(:gateway_symbol) { :stripe }

      it 'instances the Stripe module' do
        expect(service_call).to eq(gateway)
      end
    end
  end
end
