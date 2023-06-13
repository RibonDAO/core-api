# frozen_string_literal: true

require 'rails_helper'

describe Donations::BlockchainTransactions::UpdateApiOnlyTransactions do
  describe '.call' do
    subject(:command) { described_class.call }

    let!(:api_only_batch) { create(:batch, :with_integration_and_non_profit) }

    let!(:batch_with_blockchain_transaction) { create(:batch, :with_integration_and_non_profit) }

    before do
      allow(Donations::CreateBatchBlockchainDonation).to receive(:call)
      create(:blockchain_transaction, owner: batch_with_blockchain_transaction)
    end

    it 'calls the Donations::CreateBatchBlockchainDonation with failed transactions donations' do
      command
      expect(Donations::CreateBatchBlockchainDonation).to have_received(:call).with(
        non_profit: api_only_batch.non_profit,
        integration: api_only_batch.integration,
        batch: api_only_batch
      )
    end

    it 'doesnt call the Donation::CreateBatchBlockchainDonation with successfull transactions donations' do
      command
      expect(Donations::CreateBatchBlockchainDonation)
        .not_to have_received(:call).with(
          non_profit: batch_with_blockchain_transaction.non_profit,
          integration: batch_with_blockchain_transaction.integration,
          batch: batch_with_blockchain_transaction
        )
    end
  end
end
