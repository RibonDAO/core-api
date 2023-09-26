# frozen_string_literal: true

require 'rails_helper'

describe PersonPayments::BlockchainTransactions::Cause::UpdateApiOnlyTransactions do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:cause) { create(:cause) }
    let(:chain) { create(:chain) }
    let(:token) { create(:token, chain:) }
    let(:pool) { create(:pool, token:, cause:) }
    let(:valid_payment_methods) { %i[credit_card pix google_pay apple_pay] }

    let!(:api_only_payments) do
      result = []
      valid_payment_methods.each do |payment_method|
        result.push(create(:person_payment, receiver: cause, payment_method:, status: :paid))
      end
      result
    end

    let(:person_payment_with_blockchain_transaction) do
      create(:person_payment, receiver: cause, payment_method: 0)
    end
    let(:person_blockchain_transaction) do
      create(:person_blockchain_transaction, person_payment: person_payment_with_blockchain_transaction)
    end

    before do
      create(:ribon_config, default_chain_id: chain.chain_id)
      allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
    end

    it 'calls the AddGivingCauseToBlockchainJob with failed transactions PersonPayments' do
      command
      api_only_payments.each do |payment|
        expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later).with(
          amount: payment.crypto_amount,
          payment:,
          pool: payment.receiver&.default_pool
        )
      end
    end

    it 'doesnt call the AddGivingCauseToBlockchainJob with successfull transactions PersonPayments' do
      command
      expect(Givings::Payment::AddGivingCauseToBlockchainJob)
        .not_to have_received(:perform_later).with(
          amount: person_payment_with_blockchain_transaction.crypto_amount,
          payment: person_payment_with_blockchain_transaction,
          pool: person_payment_with_blockchain_transaction.receiver&.default_pool
        )
    end
  end
end
