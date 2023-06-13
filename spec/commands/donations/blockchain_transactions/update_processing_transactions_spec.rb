# frozen_string_literal: true

require 'rails_helper'

describe Donations::BlockchainTransactions::UpdateProcessingTransactions do
  describe '.call' do
    subject(:command) { described_class.call }

    let!(:processing_transactions) { create_list(:blockchain_transaction, 2, status: :processing) }
    let!(:success_transactions) { create_list(:blockchain_transaction, 2, status: :success) }

    before do
      allow(Service::Donations::BlockchainTransaction)
        .to receive(:new).and_return(OpenStruct.new({ update_status: true }))
    end

    it 'calls the Service::Donations::DonationBlockchainTransaction update_status with processing transactions' do
      command

      processing_transactions.each do |transaction|
        expect(Service::Donations::BlockchainTransaction)
          .to have_received(:new).with(blockchain_transaction: transaction)
      end

      success_transactions.each do |transaction|
        expect(Service::Donations::BlockchainTransaction)
          .not_to have_received(:new).with(blockchain_transaction: transaction)
      end
    end
  end
end
