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

  describe '#enough_tickets_balance?' do
    let(:contribution_balance) { build(:contribution_balance, tickets_balance_cents: 100) }

    context 'when the tickets balance is higher than the amount' do
      it 'returns true' do
        expect(contribution_balance.enough_tickets_balance?(50)).to be_truthy
      end
    end

    context 'when the tickets balance is lower than the amount' do
      it 'returns false' do
        expect(contribution_balance.enough_tickets_balance?(150)).to be_falsey
      end
    end
  end

  describe '.with_payment_in_blockchain' do
    let(:with_payment_in_blockchain) do
      create_list(:contribution_balance, 2,
                  contribution: create(:contribution,
                                       person_payment: create(:person_payment, :with_payment_in_blockchain)))
    end
    let(:without_payment_in_blockchain) do
      create_list(:contribution_balance, 2)
    end

    before do
      with_payment_in_blockchain
      without_payment_in_blockchain
    end

    it 'returns all the contributions that have person_payment with person_blockchain_transaction success' do
      expect(described_class.with_payment_in_blockchain.pluck(:id))
        .to match_array(with_payment_in_blockchain.pluck(:id))
    end
  end

  describe '.created_before' do
    let(:recent_contributions) do
      create_list(:contribution_balance, 2, created_at: 1.day.ago)
    end
    let(:previous_contributions) do
      create_list(:contribution_balance, 2, created_at: 5.days.ago)
    end

    before do
      recent_contributions
      previous_contributions
    end

    it 'returns all the contributions created before the passed date' do
      expect(described_class.created_before(2.days.ago)).to match_array(previous_contributions)
    end
  end

  describe '.confirmed_on_blockchain_before' do
    let(:recent_contributions) do
      create_list(:contribution_balance, 2)
    end
    let(:previous_contributions) do
      create_list(:contribution_balance, 2)
    end

    before do
      recent_contributions.each do |contribution_balance|
        create(:person_blockchain_transaction, succeeded_at: 1.day.ago,
                                               person_payment: contribution_balance.contribution.person_payment)
      end
      previous_contributions.each do |contribution_balance|
        create(:person_blockchain_transaction, succeeded_at: 5.days.ago,
                                               person_payment: contribution_balance.contribution.person_payment)
      end
    end

    it 'returns all the contributions created before the passed date' do
      expect(described_class.confirmed_on_blockchain_before(2.days.ago)).to match_array(previous_contributions)
    end
  end
end
