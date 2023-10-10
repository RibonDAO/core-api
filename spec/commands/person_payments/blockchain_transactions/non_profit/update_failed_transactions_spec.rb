# frozen_string_literal: true

require 'rails_helper'

describe PersonPayments::BlockchainTransactions::NonProfit::UpdateFailedTransactions do
  include ActiveStorage::Blob::Analyzable
  describe '.call' do
    subject(:command) { described_class.call }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:non_profit) { create(:non_profit) }
    let(:valid_payment_methods) { %i[credit_card pix google_pay apple_pay] }
    let(:failed_status) { %i[failed dropped replaced] }
    let(:not_failed_status) { %i[success processing] }

    let(:retry_transactions) do
      result = []
      valid_payment_methods.each do |payment_method|
        failed_status.each do |treasure_entry_status|
          result.push(create(:person_blockchain_transaction,
                             treasure_entry_status:,
                             person_payment: create(:person_payment, receiver: non_profit,
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
                             person_payment: create(:person_payment, receiver: non_profit,
                                                                     payment_method:,
                                                                     status: :paid)))
        end
      end
      result
    end

    before do
      retry_transactions
      not_retry_transactions
      allow(Givings::Payment::AddGivingNonProfitToBlockchainJob).to receive(:perform_later)
    end

    it 'calls the AddGivingNonProfitToBlockchainJob with failed transactions PersonPayments' do
      command

      retry_transactions.each do |transaction|
        expect(Givings::Payment::AddGivingNonProfitToBlockchainJob).to have_received(:perform_later).with(
          non_profit: transaction.person_payment.receiver,
          payment: transaction.person_payment,
          amount: transaction.person_payment.crypto_amount
        ).once
      end
    end

    it 'doesnt call the AddGivingNonProfitToBlockchainJob with successfull transactions PersonPayments' do
      command

      not_retry_transactions.each do |transaction|
        expect(Givings::Payment::AddGivingNonProfitToBlockchainJob)
          .not_to have_received(:perform_later).with(
            non_profit: transaction.person_payment.receiver,
            payment: transaction.person_payment,
            amount: transaction.person_payment.crypto_amount
          )
      end
    end
  end
end
