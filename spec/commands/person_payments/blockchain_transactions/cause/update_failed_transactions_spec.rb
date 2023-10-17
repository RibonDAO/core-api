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
    let(:valid_payment_methods) { %i[credit_card pix google_pay apple_pay] }
    let(:failed_status) { %i[failed dropped replaced] }
    let(:not_failed_status) { %i[success processing] }

    let(:retry_transactions) do
      result = []
      valid_payment_methods.each do |payment_method|
        failed_status.each do |treasure_entry_status|
          result.push(create(:person_blockchain_transaction,
                             treasure_entry_status:,
                             person_payment: create(:person_payment, receiver: cause,
                                                                     payment_method:,
                                                                     status: :paid)))
        end
      end
      result
    end

    let(:not_retry_transactions) do
      result = []
      valid_payment_methods.each do |payment_method|
        not_failed_status.each do |treasure_entry_status|
          result.push(create(:person_blockchain_transaction,
                             treasure_entry_status:,
                             person_payment: create(:person_payment, receiver: cause,
                                                                     payment_method:,
                                                                     status: :paid)))
        end
      end
      result
    end

    before do
      create(:ribon_config, default_chain_id: chain.chain_id)
      retry_transactions
      not_retry_transactions
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
