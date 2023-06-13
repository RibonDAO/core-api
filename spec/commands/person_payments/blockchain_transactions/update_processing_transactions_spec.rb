# frozen_string_literal: true

require 'rails_helper'

describe PersonPayments::BlockchainTransactions::UpdateProcessingTransactions do
  describe '.call' do
    subject(:command) { described_class.call }

    let!(:processing_transactions) do
      create_list(:person_blockchain_transaction, 2, treasure_entry_status: :processing)
    end
    let!(:success_transactions) { create_list(:person_blockchain_transaction, 2, treasure_entry_status: :success) }

    before do
      allow(PersonPaymentServices::BlockchainTransaction)
        .to receive(:new).and_return(OpenStruct.new({ update_status: true }))
    end

    it 'calls the PersonPaymentServices::BlockchainTransaction update_status with processing transactions' do
      command

      processing_transactions.each do |transaction|
        expect(PersonPaymentServices::BlockchainTransaction)
          .to have_received(:new).with(person_blockchain_transaction: transaction)
      end

      success_transactions.each do |transaction|
        expect(PersonPaymentServices::BlockchainTransaction)
          .not_to have_received(:new).with(person_blockchain_transaction: transaction)
      end
    end
  end
end
