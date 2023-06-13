require 'rails_helper'

RSpec.describe FetchContributionsWithLowRemainingAmount, type: :model do
  subject(:rule) { described_class.new(donation) }

  let(:donation) { create(:donation) }

  let(:contributions_with_less_than_10_percent_balance) do
    create_list(:contribution, 2,
                contribution_balance: create(:contribution_balance, tickets_balance_cents: 10),
                person_payment: create(:person_payment, usd_value_cents: 100))
  end
  let(:contributions_with_more_than_10_percent_balance) do
    create_list(:contribution, 2,
                contribution_balance: create(:contribution_balance, tickets_balance_cents: 50),
                person_payment: create(:person_payment, usd_value_cents: 100))
  end

  describe '#call' do
    context 'when there are contributions with less then 10 percent balance' do
      before do
        contributions_with_less_than_10_percent_balance
        contributions_with_more_than_10_percent_balance
      end

      it 'returns a contribution with less than 10 percent balance' do
        input = {
          chosen: Contribution.all,
          found: false
        }
        response = rule.call(input)

        expect(contributions_with_less_than_10_percent_balance).to include(response[:chosen])
      end
    end

    context 'when there are no contributions with less then 10 percent balance' do
      before do
        contributions_with_more_than_10_percent_balance
      end

      it 'returns the passed chosen param' do
        input = {
          chosen: Contribution.all,
          found: false
        }
        response = rule.call(input)

        expect(response[:chosen].pluck(:id)).to eq(Contribution.all.pluck(:id))
      end
    end
  end
end
