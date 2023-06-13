# frozen_string_literal: true

require 'rails_helper'

describe Donations::BlockchainTransactions::UpdateFailedTransactions do
  describe '.call' do
    subject(:command) { described_class.call }

    let(:batch) { create(:batch) }

    let(:failed_transactions_before) do
      create_list(:blockchain_transaction, 2, status: :failed, owner: batch)
    end
    let(:failed_transactions) { create_list(:blockchain_transaction, 1, status: :failed, owner: batch) }
    let(:success_transactions) { create_list(:blockchain_transaction, 2, status: :success) }

    before do
      failed_transactions_before
      failed_transactions
      success_transactions
      allow(Donations::CreateBatchBlockchainDonation).to receive(:call)
    end

    it 'calls the Donations::CreateBatchBlockchainDonation with failed transactions donations' do
      command

      failed_transactions.each do |transaction|
        expect(Donations::CreateBatchBlockchainDonation).to have_received(:call).with(
          non_profit: transaction.owner.non_profit,
          integration: transaction.owner.integration,
          batch: transaction.owner
        ).once
      end
    end

    it 'doesnt call the Donations::CreateBatchBlockchainDonation with successfull transactions donations' do
      command

      success_transactions.each do |transaction|
        expect(Donations::CreateBatchBlockchainDonation)
          .not_to have_received(:call).with(
            non_profit: transaction.owner.non_profit,
            integration: transaction.owner.integration,
            batch: transaction.owner
          )
      end
    end
  end
end
