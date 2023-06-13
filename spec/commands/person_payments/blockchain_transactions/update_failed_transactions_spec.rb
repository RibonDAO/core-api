# frozen_string_literal: true

require 'rails_helper'

describe PersonPayments::BlockchainTransactions::UpdateFailedTransactions do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:cause) { create(:cause) }
    let(:chain) { create(:chain) }
    let(:token) { create(:token, chain:) }
    let(:pool) { create(:pool, token:, cause:) }
    let(:person_payment) { create(:person_payment, receiver: cause, payment_method: :credit_card, status: :paid) }
    let(:failed_transactions) do
      create_list(:person_blockchain_transaction, 1, treasure_entry_status: :failed, person_payment:)
    end
    let(:success_transactions) do
      create_list(:person_blockchain_transaction, 2,
                  treasure_entry_status: :success,
                  person_payment: create(:person_payment,
                                         receiver: create(:cause)))
    end

    before do
      create(:ribon_config, default_chain_id: chain.chain_id)
      failed_transactions
      success_transactions
      allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
    end

    it 'calls the AddGivingCauseToBlockchainJob with failed transactions PersonPayments' do
      command

      failed_transactions.each do |transaction|
        expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later).with(
          amount: transaction.person_payment.crypto_amount,
          payment: transaction.person_payment,
          pool: transaction.person_payment.receiver&.default_pool
        ).once
      end
    end

    it 'doesnt call the AddGivingCauseToBlockchainJob with successfull transactions PersonPayments' do
      command

      success_transactions.each do |transaction|
        expect(Givings::Payment::AddGivingCauseToBlockchainJob)
          .not_to have_received(:perform_later).with(
            amount: transaction.person_payment.crypto_amount,
            payment: transaction.person_payment,
            pool: transaction.person_payment.receiver&.default_pool
          )
      end
    end
  end
end
