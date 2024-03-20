require 'rails_helper'

RSpec.describe RuleGroup, type: :model do
  let(:donation) { instance_double(Donation, value: 10) }
  let(:rule_group) { described_class.new(donation) }
  let(:contribution_balance1) { create(:contribution_balance, tickets_balance_cents: 500) }
  let(:contribution_balance2) { create(:contribution_balance, tickets_balance_cents: 1000) }
  let(:contribution1) { create(:contribution, contribution_balance: contribution_balance1) }
  let(:contribution2) { create(:contribution, contribution_balance: contribution_balance2) }
  let(:contributions) { [contribution1, contribution2] }

  describe '#rules_set' do
    it 'returns the right order for the rules set' do
      expect(described_class.rules_set).to eq([ChooseBetweenBigDonorsAndPromoters,
                                               ChooseContributionsCause,
                                               FetchContributionsWithLowRemainingAmount,
                                               PickContributionBasedOnMoney])
    end
  end

  describe '#total_payments_from' do
    describe 'when the total tickets balance is higher than the donation value' do
      it 'returns the total payments from the given contributions' do
        expect(rule_group.total_payments_from(contributions)).to eq(1500)
      end
    end

    describe 'when the total tickets balance is lower than the donation value' do
      let(:contribution_balance1) do
        create(:contribution_balance, tickets_balance_cents: 1, fees_balance_cents: 500)
      end
      let(:contribution_balance2) do
        create(:contribution_balance, tickets_balance_cents: 1, fees_balance_cents: 1400)
      end
      let(:contribution1) { create(:contribution, contribution_balance: contribution_balance1) }
      let(:contribution2) { create(:contribution, contribution_balance: contribution_balance2) }
      let(:contributions) { [contribution1, contribution2] }

      it 'returns the total payments from the given contributions' do
        expect(rule_group.total_payments_from(contributions)).to eq(1900)
      end
    end
  end

  describe '#empty' do
    it 'returns a hash with nil chosen and false found values' do
      expect(rule_group.send(:empty)).to eq({ chosen: [], found: false })
    end
  end
end
