# frozen_string_literal: true

require 'rails_helper'

describe Integrations::CreateIntegration do
  describe '.call' do
    subject(:command) { described_class.call(name:, status:) }

    context 'when all the data is valid' do
      let(:name) { 'Ribon' }
      let(:status) { :active }

      it 'creates a new integration' do
        expect { command }.to change(Integration, :count).by(1)
      end

      it 'creates a new integration wallet' do
        expect { command }.to change(IntegrationWallet, :count).by(1)
      end
    end

    context 'when a data is invalid' do
      let(:name) { 'Ribon' }
      let(:status) { :undefined }

      it 'raises an error' do
        expect(command.errors).to eq({ message: ["'undefined' is not a valid status"] })
      end

      it 'does not create a new integration' do
        expect { command }.not_to change(Integration, :count)
      end

      it 'does not create a new integration wallet' do
        expect { command }.not_to change(IntegrationWallet, :count)
      end
    end
  end
end
