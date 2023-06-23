# frozen_string_literal: true

require 'rails_helper'

describe Donations::BlockchainTransactions::UpdateFailedTransactions do
  describe '.call' do
    subject(:command) { described_class.call }

    let(:retry_transactions_before) do
      [create(:blockchain_transaction, status: :failed),
       create(:blockchain_transaction, status: :dropped),
       create(:blockchain_transaction, status: :replaced)]
    end

    let(:retry_transactions) do
      [create(:blockchain_transaction, status: :failed),
       create(:blockchain_transaction, status: :dropped),
       create(:blockchain_transaction, status: :replaced)]
    end

    let(:not_retry_transactions) do
      [create(:blockchain_transaction, status: :success),
       create(:blockchain_transaction, status: :processing)]
    end

    before do
      retry_transactions_before
      retry_transactions
      allow(Donations::CreateBatchBlockchainDonation).to receive(:call)
    end

    it 'calls the Donations::CreateBatchBlockchainDonation with retry transactions donations' do
      command

      retry_transactions.each do |transaction|
        expect(Donations::CreateBatchBlockchainDonation).to have_received(:call).with(
          non_profit: transaction.owner.non_profit,
          integration: transaction.owner.integration,
          batch: transaction.owner
        ).once
      end
    end

    it 'doesnt call the Donations::CreateBatchBlockchainDonation with no retry transactions donations' do
      command
      not_retry_transactions
      not_retry_transactions.each do |transaction|
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
