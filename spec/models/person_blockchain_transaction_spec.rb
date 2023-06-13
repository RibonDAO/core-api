# == Schema Information
#
# Table name: person_blockchain_transactions
#
#  id                    :bigint           not null, primary key
#  transaction_hash      :string
#  treasure_entry_status :integer          default("processing")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_payment_id     :bigint
#
require 'rails_helper'

RSpec.describe PersonBlockchainTransaction, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to(:person_payment) }
    it { is_expected.to define_enum_for(:treasure_entry_status).with_values(%i[processing success failed]) }
  end

  describe 'after update with status success and receiver type cause' do
    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }
    let(:pool) { create(:pool) }
    let!(:cause) { create(:cause) }
    let!(:person_payment) { create(:person_payment, receiver: cause) }
    let(:person_blockchain_transaction) { create(:person_blockchain_transaction, person_payment:) }
    let(:service) { Service::Donations::PoolBalances }
    let(:service_mock) { instance_double(service) }

    before do
      allow(cause).to receive(:default_pool).and_return(pool)
      allow(service).to receive(:new).with(pool:).and_return(service_mock)
      allow(service_mock).to receive(:increase_balance)
      person_blockchain_transaction.update(treasure_entry_status: :success)
    end

    it 'calls increase_pool_balance' do
      expect(service).to have_received(:new).with(pool:)
      expect(service_mock).to have_received(:increase_balance)
    end
  end

  describe 'after update with status success and receiver type NonProfit' do
    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }
    let(:pool) { create(:pool) }
    let!(:non_profit) { create(:non_profit) }
    let!(:person_payment) { create(:person_payment, receiver: non_profit) }
    let(:person_blockchain_transaction) { create(:person_blockchain_transaction, person_payment:) }
    let(:service) { Service::Donations::PoolBalances }
    let(:service_mock) { instance_double(service) }

    before do
      allow(service).to receive(:new).with(pool:).and_return(service_mock)
      allow(service_mock).to receive(:increase_balance)
      person_blockchain_transaction.update(treasure_entry_status: :success)
    end

    it 'calls increase_pool_balance' do
      expect(service).not_to have_received(:new).with(pool:)
      expect(service_mock).not_to have_received(:increase_balance)
    end
  end
end
