require 'rails_helper'

RSpec.describe ContributionQueries, type: :model do
  describe '#ordered_feeable_contribution_balances' do
    let(:contribution) { create(:contribution) }
    let!(:contribution_balance1) { create(:contribution_balance, :with_paid_status, fees_balance_cents: 5) }
    let!(:contribution_balance2) { create(:contribution_balance, :with_paid_status, fees_balance_cents: 15) }
    let!(:contribution_balance3) { create(:contribution_balance, :with_paid_status, fees_balance_cents: 25) }

    it 'returns the contribution balances paid with fees balance ordered by fees balance' do
      expect(described_class.new(contribution:).ordered_feeable_contribution_balances)
        .to eq [contribution_balance1, contribution_balance2, contribution_balance3]
    end
  end
end
