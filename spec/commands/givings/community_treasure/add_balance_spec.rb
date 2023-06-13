# frozen_string_literal: true

require 'rails_helper'

describe Givings::CommunityTreasure::AddBalance do
  describe '.call' do
    subject(:command) { described_class.call(amount:) }

    let(:amount) { 0.5 }
    let(:feeable) { true }
    let(:ribon_contract) { instance_double(Web3::Contracts::RibonContract) }
    let!(:chain) { create(:chain) }
    let!(:donation_pool) { create(:pool, token: create(:token, chain:)) }

    before do
      allow(Web3::Contracts::RibonContract).to receive(:new).and_return(ribon_contract)
      allow(ribon_contract).to receive(:add_pool_balance)
      create(:ribon_config, default_chain_id: chain.chain_id)
    end

    it 'calls ribon contract add_pool_balance with correct args' do
      command

      expect(ribon_contract).to have_received(:add_pool_balance).with(donation_pool:, amount:, feeable:)
    end
  end
end
