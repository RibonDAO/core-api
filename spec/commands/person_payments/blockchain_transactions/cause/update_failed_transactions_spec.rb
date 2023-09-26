# frozen_string_literal: true

require 'rails_helper'

describe PersonPayments::BlockchainTransactions::Cause::UpdateFailedTransactions do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:cause) { create(:cause) }
    let(:chain) { create(:chain) }
    let(:token) { create(:token, chain:) }
    let(:pool) { create(:pool, token:, cause:) }

    let(:retry_transactions_before) do
      [create(:person_blockchain_transaction,
              treasure_entry_status: :failed,
              person_payment: create(:person_payment, receiver: cause, payment_method: :credit_card,
                                                      status: :paid)),
       create(:person_blockchain_transaction,
              treasure_entry_status: :dropped,
              person_payment: create(:person_payment, receiver: cause, payment_method: :pix,
                                                      status: :paid)),
       create(:person_blockchain_transaction,
              treasure_entry_status: :replaced,
              person_payment: create(:person_payment, receiver: cause, payment_method: :google_pay,
                                                      status: :paid))]
    end

    let(:retry_transactions) do
      [create(:person_blockchain_transaction,
              treasure_entry_status: :failed,
              person_payment: create(:person_payment, receiver: cause, payment_method: :credit_card,
                                                      status: :paid)),
       create(:person_blockchain_transaction,
              treasure_entry_status: :dropped,
              person_payment: create(:person_payment, receiver: cause, payment_method: :pix,
                                                      status: :paid)),
       create(:person_blockchain_transaction,
              treasure_entry_status: :replaced,
              person_payment: create(:person_payment, receiver: cause, payment_method: :google_pay,
                                                      status: :paid))]
    end

    let(:not_retry_transactions) do
      [create(:person_blockchain_transaction,
              treasure_entry_status: :success,
              person_payment: create(:person_payment, receiver: cause, payment_method: :credit_card,
                                                      status: :paid)),
       create(:person_blockchain_transaction,
              treasure_entry_status: :processing,
              person_payment: create(:person_payment, receiver: cause, payment_method: :pix,
                                                      status: :paid))]
    end

    before do
      create(:ribon_config, default_chain_id: chain.chain_id)
      retry_transactions_before
      retry_transactions
      allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
    end

    it 'calls the AddGivingCauseToBlockchainJob with failed transactions PersonPayments' do
      command

      retry_transactions.each do |transaction|
        expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later).with(
          amount: transaction.person_payment.crypto_amount,
          payment: transaction.person_payment,
          pool: transaction.person_payment.receiver&.default_pool
        ).once
      end
    end

    it 'doesnt call the AddGivingCauseToBlockchainJob with successfull transactions PersonPayments' do
      command

      not_retry_transactions
      not_retry_transactions.each do |transaction|
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
