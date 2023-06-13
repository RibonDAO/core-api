# frozen_string_literal: true

require 'rails_helper'

describe PersonPayments::BlockchainTransactions::UpdateApiOnlyTransactions do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:cause) { create(:cause) }
    let(:chain) { create(:chain) }
    let(:token) { create(:token, chain:) }
    let(:pool) { create(:pool, token:, cause:) }
    let!(:api_only_person) do
      create(:person_payment, receiver: cause, payment_method: :credit_card, status: :paid)
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
      expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later).with(
        amount: api_only_person.crypto_amount,
        payment: api_only_person,
        pool: api_only_person.receiver&.default_pool
      )
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
