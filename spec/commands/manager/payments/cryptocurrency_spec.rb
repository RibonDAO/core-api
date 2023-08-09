# frozen_string_literal: true

require 'rails_helper'

describe Manager::Payments::Cryptocurrency do
  describe '.call' do
    subject(:command) { described_class.call(args) }

    let!(:integration) { create(:integration) }
    let!(:cause) { create(:cause) }

    describe '.call returns success' do
      let(:transaction_hash) { '0xFFFF' }
      let!(:big_donor) { create(:big_donor) }

      let(:args) do
        { payer: big_donor, amount: '7.00', transaction_hash:,
          integration_id: integration.id, receiver: cause, create_contribution_command: }
      end
      let(:create_contribution_command) { Contributions::CreateContribution }

      it 'creates a PersonPayment' do
        expect { command }.to change(PersonPayment, :count).by(1)
      end

      it 'creates a PersonBlockchainTransaction' do
        expect { command }.to change(PersonBlockchainTransaction, :count).by(1)
      end

      it 'returns success' do
        expect(command).to be_success
      end

      it 'calls the create contribution command' do
        allow(Contributions::CreateContribution).to receive(:call)
        command

        expect(Contributions::CreateContribution).to have_received(:call)
      end
    end

    describe '.call returns error' do
      let(:transaction_hash) { '0xFFFF' }

      let(:args) do
        { payer: nil, amount: '7.00', transaction_hash:, integration_id: integration.id, receiver: cause }
      end

      it 'does not create a PersonPayment' do
        expect { command }.not_to change(PersonPayment, :count)
      end

      it 'does not create a PersonBlockchainTransaction' do
        expect { command }.not_to change(PersonBlockchainTransaction, :count)
      end

      it 'return errors' do
        expect(command).to be_failure
      end
    end
  end
end
