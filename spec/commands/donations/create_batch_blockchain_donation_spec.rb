# frozen_string_literal: true

require 'rails_helper'

describe Donations::CreateBatchBlockchainDonation do
  describe '.call' do
    subject(:command) { described_class.call(non_profit:, integration:, batch:) }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit) }
      let(:batch) { create(:batch) }
      let(:ribon_contract) { instance_double(Web3::Contracts::RibonContract) }
      let!(:chain) { create(:chain) }
      let!(:token) { create(:token, chain:) }
      let!(:donation_pool) { create(:pool, token:) }

      before do
        allow(Kernel).to receive(:sleep)
        allow(Web3::Contracts::RibonContract).to receive(:new).and_return(ribon_contract)
        allow(ribon_contract).to receive(:donate_through_integration).and_return('0xFF20')
        create(:ribon_config, default_ticket_value: 100, default_chain_id: chain.chain_id)
      end

      it 'calls the donate in contract' do
        command

        expect(ribon_contract).to have_received(:donate_through_integration)
          .with(donation_pool:, amount: 1.0,
                non_profit_wallet_address: non_profit.wallet_address,
                integration_wallet_address: integration.wallet_address,
                donation_batch: batch.cid)
      end

      it 'creates blockchain_transaction for the batch' do
        command

        expect(batch.blockchain_transaction.transaction_hash).to eq '0xFF20'
        expect(batch.blockchain_transaction.chain.chain_id).to eq chain.chain_id
      end

      it 'returns the donation blockchain transaction' do
        expect(command.result.transaction_hash).to eq '0xFF20'
      end

      context 'when the non profit has a cause with a pool' do
        let!(:new_pool) { create(:pool, token:, cause:) }
        let(:non_profit) { create(:non_profit, cause:) }
        let(:cause) { create(:cause) }
        let(:batch) { create(:batch) }

        it 'calls the donate in contract with the new pool' do
          command

          expect(ribon_contract)
            .to have_received(:donate_through_integration)
            .with(donation_pool: new_pool, amount: 1.0,
                  non_profit_wallet_address: non_profit.wallet_address,
                  integration_wallet_address: integration.wallet_address,
                  donation_batch: batch.cid)
        end
      end
    end

    context 'when an error occurs at the blockchain process' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit) }
      let(:batch) { create(:batch) }
      let(:user) { create(:user) }
      let(:ribon_contract) { instance_double(Web3::Contracts::RibonContract) }

      before do
        allow(Kernel).to receive(:sleep)
        create(:ribon_config, default_ticket_value: 100)
        allow(Web3::Contracts::RibonContract).to receive(:new).and_return(ribon_contract)
        allow(ribon_contract).to receive(:donate_through_integration)
          .and_raise(StandardError.new('error message'))
      end

      it 'raises the error' do
        expect { command }.to raise_error(StandardError)
      end
    end
  end
end
