# == Schema Information
#
# Table name: donation_contributions
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contribution_id :bigint           not null
#  donation_id     :bigint           not null
#
require 'rails_helper'

RSpec.describe DonationContribution, type: :model do
  describe '.validations' do
    subject { build(:donation_contribution) }

    it { is_expected.to belong_to(:donation) }
    it { is_expected.to belong_to(:contribution) }
  end

  describe '.last_contribution_payer_type' do
    let(:contribution) { create(:contribution, person_payment: create(:person_payment, payer: create(:customer))) }

    before do
      create(:donation_contribution, contribution:)
    end

    it 'returns the payer type of the last contribution' do
      expect(described_class.last_contribution_payer_type).to eq('Customer')
    end
  end
end
