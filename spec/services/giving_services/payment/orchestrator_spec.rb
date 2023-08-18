require 'rails_helper'

RSpec.describe GivingServices::Payment::Orchestrator, type: :service do
  subject(:service_call) { described_class.new(payload:).call }

  describe '#call' do
    let(:credit_card) { build(:credit_card) }
    let(:person_payment) { build(:person_payment) }
    let(:payload) { Order.from(person_payment, credit_card, operation) }

    let(:gateway) { Payment::Gateways::Stripe }
    let!(:gateway_instance) do
      mock_instance(klass: gateway::PaymentProcessor, mock_methods: %i[purchase subscribe unsubscribe])
    end

    context 'when is a purchase operation' do
      let(:operation) { :purchase }

      it 'calls PaymentProcessor#purchase method' do
        service_call

        expect(gateway_instance).to have_received(operation)
      end
    end

    context 'when is a subscribe operation' do
      let(:operation) { :subscribe }

      it 'calls PaymentProcessor#subscribe method' do
        service_call

        expect(gateway_instance).to have_received(operation)
      end
    end

    context 'when is a unsubscribe operation' do
      let(:operation) { :unsubscribe }

      it 'calls PaymentProcessor#unsubscribe method' do
        service_call

        expect(gateway_instance).to have_received(operation)
      end
    end
  end
end
