# frozen_string_literal: true

require 'rails_helper'

describe Donations::UpdateProcessingDonations do
  describe '.call' do
    subject(:command) { described_class.call }

    let!(:processing_transactions) { create_list(:donation_blockchain_transaction, 2, status: :processing) }
    let!(:success_transactions) { create_list(:donation_blockchain_transaction, 2, status: :success) }

    before do
      allow(DonationServices::DonationBlockchainTransaction)
        .to receive(:new).and_return(OpenStruct.new({ update_status: true }))
    end

    it 'calls the DonationServices::DonationBlockchainTransaction update_status with processing transactions' do
      command

      processing_transactions.each do |transaction|
        expect(DonationServices::DonationBlockchainTransaction)
          .to have_received(:new).with(donation_blockchain_transaction: transaction)
      end

      success_transactions.each do |transaction|
        expect(DonationServices::DonationBlockchainTransaction)
          .not_to have_received(:new).with(donation_blockchain_transaction: transaction)
      end
    end
  end
end
