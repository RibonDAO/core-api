# == Schema Information
#
# Table name: donations
#
#  id             :bigint           not null, primary key
#  platform       :string
#  value          :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint           not null
#  non_profit_id  :bigint           not null
#  user_id        :bigint
#
require 'rails_helper'

RSpec.describe Donation, type: :model do
  describe '.validations' do
    subject { build(:donation) }

    it { is_expected.to belong_to(:non_profit) }
    it { is_expected.to belong_to(:integration) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one(:donation_contribution) }
  end

  describe '.without_label' do
    let!(:donations_without_label) { create_list(:donation, 2) }
    let(:donations_with_label) { create_list(:donation, 2) }

    before do
      donations_with_label.each do |donation|
        create(:donation_contribution, donation:)
      end
    end

    it 'returns all the donations that are not yet labeled' do
      expect(described_class.without_label.pluck(:id))
        .to match_array(donations_without_label.pluck(:id))
    end
  end

  describe '#impact_value' do
    let(:non_profit) { create(:non_profit, :with_impact) }
    let(:donation) { build(:donation, non_profit:, value: 100) }

    it 'returns the impact that one donation has according to the non profit' do
      expect(donation.impact_value).to eq 10
    end
  end

  describe '#impact' do
    let(:non_profit) { create(:non_profit, :with_impact, impact_description: 'impacts') }
    let(:donation) { build(:donation, non_profit:, value: 100) }

    it 'returns the impact value with the non profit impact description' do
      expect(donation.impact).to eq '10 impacts'
    end
  end

  describe '#donation_blockchain_transaction' do
    subject(:donation) { create(:donation) }

    it 'returns the last donation blockchain transaction' do
      create(:donation_blockchain_transaction, donation:, transaction_hash: '0x001')
      dbt2 = create(:donation_blockchain_transaction, donation:, transaction_hash: '0x002')

      expect(donation.donation_blockchain_transaction).to eq dbt2
    end
  end

  describe '#create_donation_blockchain_transaction' do
    subject(:donation) { create(:donation) }

    let(:chain) { create(:chain) }

    it 'creates a new donation_blockchain_transaction' do
      expect { donation.create_donation_blockchain_transaction(transaction_hash: '0x001', chain:) }
        .to change { donation.donation_blockchain_transactions.count }.by(1)
    end
  end

  describe '#cause' do
    let(:cause) { create(:cause) }
    let(:non_profit) { create(:non_profit, cause:) }
    let(:donation) { create(:donation, non_profit:) }

    it 'returns the non profit cause' do
      expect(donation.cause).to eq cause
    end
  end
end
