# frozen_string_literal: true

require 'rails_helper'

describe Givings::NonProfitTreasure::AddBalance do
  describe '.call' do
    subject(:command) { described_class.call(amount:, non_profit:, chain:) }

    let(:amount) { 0.5 }
    let(:ribon_contract) { instance_double(Web3::Contracts::RibonContract) }
    let!(:chain) { create(:chain) }
    let!(:cause) { create(:cause) }
    let!(:non_profit_pool) { create(:pool, token: create(:token, chain:), cause:) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:non_profit_wallet_address) { non_profit.wallet_address }

    before do
      allow(Kernel).to receive(:sleep)
      allow(Web3::Contracts::RibonContract).to receive(:new).and_return(ribon_contract)
      allow(ribon_contract).to receive(:contribute_to_non_profit)
      create(:ribon_config, default_chain_id: chain.chain_id)
    end

    it 'calls ribon contract contribute_to_non_profit with correct args' do
      command

      expect(ribon_contract).to have_received(:contribute_to_non_profit).with(non_profit_pool:,
                                                                              non_profit_wallet_address:, amount:)
    end
  end
end
