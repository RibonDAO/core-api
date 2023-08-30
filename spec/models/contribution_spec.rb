# == Schema Information
#
# Table name: contributions
#
#  id                  :bigint           not null, primary key
#  generated_fee_cents :integer
#  receiver_type       :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  person_payment_id   :bigint           not null
#  receiver_id         :bigint           not null
#
require 'rails_helper'

RSpec.describe Contribution, type: :model do
  describe '.validations' do
    subject { build(:contribution) }

    it { is_expected.to belong_to(:person_payment) }
    it { is_expected.to belong_to(:receiver) }
    it { is_expected.to have_one(:contribution_balance) }
    it { is_expected.to have_many(:donation_contributions) }
  end

  describe '.with_tickets_balance_higher_than' do
    before do
      create(:contribution, contribution_balance: create(:contribution_balance, tickets_balance_cents: 10), id: 1)
      create(:contribution, contribution_balance: create(:contribution_balance, tickets_balance_cents: 10), id: 2)
      create(:contribution, contribution_balance: create(:contribution_balance, tickets_balance_cents: 0), id: 3)
    end

    it 'returns all the contributions which have tickets balance' do
      expect(described_class.with_tickets_balance_higher_than(5).pluck(:id)).to match_array [1, 2]
    end
  end

  describe '.with_fees_balance_higher_than' do
    before do
      create(:contribution, contribution_balance: create(:contribution_balance, fees_balance_cents: 10), id: 1)
      create(:contribution, contribution_balance: create(:contribution_balance, fees_balance_cents: 10), id: 2)
      create(:contribution, contribution_balance: create(:contribution_balance, fees_balance_cents: 0), id: 3)
    end

    it 'returns all the contributions which have tickets balance' do
      expect(described_class.with_fees_balance_higher_than(5).pluck(:id)).to match_array [1, 2]
    end
  end

  describe '.from_unique_donors' do
    before do
      create(:contribution, person_payment: create(:person_payment, payer: create(:customer)), id: 1)
      create(:contribution, person_payment: create(:person_payment, payer: create(:customer)), id: 2)
      create(:contribution, person_payment: create(:person_payment, payer: create(:big_donor)), id: 3)
    end

    it 'returns all the contributions which have tickets balance' do
      expect(described_class.from_unique_donors.pluck(:id)).to match_array [1, 2]
    end
  end

  describe '.from_big_donors' do
    before do
      create(:contribution, person_payment: create(:person_payment, payer: create(:customer)), id: 1)
      create(:contribution, person_payment: create(:person_payment, payer: create(:customer)), id: 2)
      create(:contribution, person_payment: create(:person_payment, payer: create(:big_donor)), id: 3)
    end

    it 'returns all the contributions which have tickets balance' do
      expect(described_class.from_big_donors.pluck(:id)).to match_array [3]
    end
  end

  describe '.ordered_by_donation_contribution' do
    let(:contribution1) do
      create(:contribution,
             person_payment: create(:person_payment, payer: create(:customer)), id: 1)
    end
    let(:contribution2) do
      create(:contribution,
             person_payment: create(:person_payment, payer: create(:customer)), id: 2)
    end
    let(:contribution3) do
      create(:contribution,
             person_payment: create(:person_payment, payer: create(:big_donor)), id: 3)
    end
    let(:contribution4) do
      create(:contribution,
             person_payment: create(:person_payment, payer: create(:big_donor)), id: 4)
    end

    before do
      contribution3
      create(:donation_contribution, created_at: 2.days.ago, contribution: contribution1)
      create(:donation_contribution, created_at: 1.day.ago, contribution: contribution2)
      create(:donation_contribution, created_at: 1.hour.ago, contribution: contribution4)
    end

    it 'returns all the contributions ordered by the most recent labeled contribution' do
      expect(described_class.ordered_by_donation_contribution.pluck(:id)).to eq [4, 2, 1, 3]
    end
  end

  describe '.with_paid_status' do
    let(:contributions_refunded) do
      create_list(:contribution, 2,
                  person_payment: create(:person_payment, status: :refunded))
    end
    let(:contributions_paid) do
      create_list(:contribution, 2,
                  person_payment: create(:person_payment, status: :paid))
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

  describe '#set_contribution_balance' do
    let(:contribution) { create(:contribution, receiver:, person_payment:) }
    let(:receiver) { create(:cause) }
    let(:person_payment) { create(:person_payment, usd_value_cents: 1000) }

    before do
      create(:ribon_config, contribution_fee_percentage: 20)
    end

    context 'when there is a contribution balance already created' do
      before do
        create(:contribution_balance, contribution:)
      end

      it 'does not create another contribution balance' do
        expect { contribution.set_contribution_balance }.not_to change(ContributionBalance, :count)
      end
    end

    context 'when the receiver is a non profit' do
      let(:receiver) { create(:non_profit) }

      it 'does not create another contribution balance' do
        expect { contribution.set_contribution_balance }.not_to change(ContributionBalance, :count)
      end
    end

    context 'when the receiver is a cause' do
      it 'sets the tickets and fee balances correctly' do
        contribution.set_contribution_balance

        expect(contribution.contribution_balance.tickets_balance_cents).to eq(800)
        expect(contribution.contribution_balance.fees_balance_cents).to eq(200)
      end
    end
  end

  describe '#label' do
    let(:receiver) { create(:cause, name: 'Cause name') }
    let(:contribution) { create(:contribution, receiver:, created_at: '2023-05-01') }

    it 'returns the cause name and reference date of the contribution' do
      expect(contribution.label).to eq('Cause name (May/2023)')
    end
  end

  describe '#non_profits' do
    context 'when the receiver is a non profit' do
      let(:receiver) { create(:non_profit) }
      let(:contribution) { create(:contribution, receiver:) }

      it 'returns an array with that non profit' do
        expect(contribution.non_profits).to eq([receiver])
      end
    end

    context 'when the receiver is a cause' do
      let(:receiver) { create(:cause) }
      let!(:non_profits) { create_list(:non_profit, 2, cause: receiver) }
      let(:contribution) { create(:contribution, receiver:) }

      it 'returns an array with all the non profits of the cause' do
        expect(contribution.non_profits.pluck(:id)).to eq(non_profits.pluck(:id))
      end
    end
  end

  describe '.with_cause_receiver' do
    let(:receiver) { create(:cause) }
    let!(:contributions) { create_list(:contribution, 2, receiver:) }

    before do
      create_list(:contribution, 2, receiver: create(:non_profit, cause: receiver))
    end

    it 'returns the contributions to causes' do
      expect(described_class.with_cause_receiver.pluck(:id)).to match_array(contributions.pluck(:id))
    end
  end

  describe '.with_payment_in_blockchain' do
    before do
      create(:contribution, person_payment: create(:person_payment, :with_payment_in_blockchain), id: 1)
      create(:contribution, person_payment: create(:person_payment, :with_payment_in_blockchain), id: 2)
      create(:contribution, person_payment: create(:person_payment), id: 3)
    end

    it 'returns all the contributions which have a payment in blockchain already' do
      expect(described_class.with_payment_in_blockchain.pluck(:id)).to match_array [1, 2]
    end
  end

  describe '#already_spread_fees?' do
    let(:contribution) { create(:contribution) }

    context 'when there are contribution fees created' do
      before do
        create(:contribution_fee, contribution:)
      end

      it 'returns true' do
        expect(contribution.already_spread_fees?).to be_truthy
      end
    end

    context 'when there are no contribution fees created' do
      it 'returns false' do
        expect(contribution.already_spread_fees?).to be_falsey
      end
    end
  end

  describe '.created_before' do
    let(:recent_contributions) do
      create_list(:contribution, 2, created_at: 1.day.ago)
    end
    let(:previous_contributions) do
      create_list(:contribution, 2, created_at: 5.days.ago)
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
      create_list(:contribution, 2, person_payment: create(:person_payment))
    end
    let(:previous_contributions) do
      create_list(:contribution, 2, person_payment: create(:person_payment))
    end

    before do
      recent_contributions.each do |contribution|
        create(:person_blockchain_transaction, succeeded_at: 1.day.ago,
                                               person_payment: contribution.person_payment)
      end
      previous_contributions.each do |contribution|
        create(:person_blockchain_transaction, succeeded_at: 5.days.ago,
                                               person_payment: contribution.person_payment)
      end
    end

    it 'returns all the contributions created before the passed date' do
      expect(described_class.confirmed_on_blockchain_before(2.days.ago)).to match_array(previous_contributions)
    end
  end
end
