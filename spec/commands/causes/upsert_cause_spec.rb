# frozen_string_literal: true

require 'rails_helper'

describe Causes::UpsertCause do
  describe '.call' do
    subject(:command) { described_class.call(cause_params) }

    context 'when create with the right params' do
      let(:cause_params) do
        {
          name: 'New Cause'
        }
      end
      let(:pools) { build(:fetch_pools_query) }
      let(:chain) { create(:chain) }
      let(:token) { create(:token, chain:) }
      let(:ribon_contract) { instance_double(Web3::Contracts::RibonContract) }
      let(:transaction_utils) { instance_double(Web3::Utils::TransactionUtils) }
      let(:transaction_hash) { '0xeba1bb09c8d20be6d4a18e0485e331b4a15e9e9e7f04fe50a44c97f923e08b58' }
      let(:pool_address) { pools.data.pools.last.id }

      before do
        allow(Token).to receive(:default).and_return(token)
        allow(Web3::Contracts::RibonContract).to receive(:new).and_return(ribon_contract)
        allow(ribon_contract).to receive(:create_pool).and_return(transaction_hash)
        create(:ribon_config, default_chain_id: chain.chain_id)
      end

      context 'when create and have success' do
        it 'creates a new cause' do
          command
          expect(Cause.count).to eq(1)
        end
      end
    end

    context 'when update with the right params' do
      let(:cause) { create(:cause) }
      let(:cause_params) do
        {
          id: cause.id,
          name: 'New Name'
        }
      end

      it 'updates the cause with a new name' do
        command
        expect(cause.reload.name).to eq('New Name')
      end
    end

    context 'when update with the wrong params' do
      let(:cause_params) do
        {
          id: 'abc',
          name: ''
        }
      end

      it 'adds an error message' do
        result = command
        expect(result.errors[:message]).to eq([I18n.t('causes.update_failed')])
      end
    end
  end
end
