# == Schema Information
#
# Table name: person_blockchain_transactions
#
#  id                    :bigint           not null, primary key
#  succeeded_at          :datetime
#  transaction_hash      :string
#  treasure_entry_status :integer          default("processing")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_payment_id     :bigint
#
require 'rails_helper'

RSpec.describe PersonBlockchainTransaction, type: :model do
  describe 'validations' do
    subject(:person_blockchain_transaction) { build(:person_blockchain_transaction) }

    it { is_expected.to belong_to(:person_payment) }

    it {
      expect(person_blockchain_transaction).to define_enum_for(
        :treasure_entry_status
      ).with_values(%i[processing success failed dropped
                       replaced])
    }
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

  describe '#retry?' do
    %w[failed dropped replaced].each do |treasure_entry_status|
      context 'when treasure_entry_status is failed or dropped or replaced' do
        subject(:person_blockchain_transaction) do
          build(:person_blockchain_transaction, treasure_entry_status:)
        end

        it 'returns true' do
          expect(person_blockchain_transaction.retry?).to be true
        end
      end
    end

    %w[processing success].each do |treasure_entry_status|
      context 'when treasure_entry_status is failed or dropped or replaced' do
        subject(:person_blockchain_transaction) do
          build(:person_blockchain_transaction, treasure_entry_status:)
        end

        it 'returns false' do
          expect(person_blockchain_transaction.retry?).to be false
        end
      end
    end
  end

  describe '#charge_contribution_fees' do
    let!(:cause) { create(:cause) }
    let!(:person_payment) { create(:person_payment, receiver: cause) }
    let!(:contribution) { create(:contribution, person_payment:) }
    let(:person_blockchain_transaction) do
      create(:person_blockchain_transaction, person_payment:,
                                             treasure_entry_status: :success)
    end
    let(:fees_service) { Service::Contributions::FeesLabelingService }
    let(:fees_service_mock) { instance_double(fees_service) }

    before do
      allow(fees_service).to receive(:new).and_return(fees_service_mock)
      allow(fees_service_mock).to receive(:spread_fee_to_payers)
    end

    context 'when the treasury entry status changed to success' do
      before do
        allow(person_blockchain_transaction).to receive(:treasure_entry_status_changed?).and_return(true)
      end

      it 'calls charge_contribution_fees' do
        person_blockchain_transaction.charge_contribution_fees

        expect(fees_service).to have_received(:new).with(contribution:)
        expect(fees_service_mock).to have_received(:spread_fee_to_payers)
      end
    end

    context 'when the treasury entry status did not change' do
      before do
        allow(person_blockchain_transaction).to receive(:treasure_entry_status_changed?).and_return(false)
      end

      it 'does not call charge_contribution_fees' do
        person_blockchain_transaction.charge_contribution_fees

        expect(fees_service).not_to have_received(:new)
        expect(fees_service_mock).not_to have_received(:spread_fee_to_payers)
      end
    end
  end
end
