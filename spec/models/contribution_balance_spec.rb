# == Schema Information
#
# Table name: contribution_balances
#
#  id                                  :bigint           not null, primary key
#  contribution_increased_amount_cents :integer
#  fees_balance_cents                  :integer
#  tickets_balance_cents               :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  contribution_id                     :bigint           not null
#
require 'rails_helper'

RSpec.describe ContributionBalance, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:contribution) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:tickets_balance_cents) }
    it { is_expected.to validate_presence_of(:fees_balance_cents) }
    it { is_expected.to validate_presence_of(:contribution_increased_amount_cents) }
  end

  describe '.with_paid_status' do
    let(:contributions_refunded) do
      create_list(:contribution_balance, 2,
                  contribution: create(:contribution,
                                       person_payment: create(:person_payment, status: :refunded)))
    end
    let(:contributions_paid) do
      create_list(:contribution_balance, 2,
                  contribution: create(:contribution,
                                       person_payment: create(:person_payment, status: :paid)))
    end

    before do
      contributions_paid
      contributions_refunded
    end

    it 'returns all the contributions that have person_payment status paid' do
      expect(described_class.with_paid_status.pluck(:id))
        .to match_array(contributions_paid.pluck(:id))
    end
  end

  describe '.with_fees_balance' do
    let(:with_balance) do
      create_list(:contribution_balance, 2, fees_balance_cents: 100)
    end
    let(:without_balance) do
      create_list(:contribution_balance, 2, fees_balance_cents: 0)
    end

    before do
      with_balance
      without_balance
    end

    it 'returns all the contributions that have person_payment status paid' do
      expect(described_class.with_fees_balance.pluck(:id))
        .to match_array(with_balance.pluck(:id))
    end
  end
end
