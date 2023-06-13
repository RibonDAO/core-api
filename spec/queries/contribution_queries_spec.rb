require 'rails_helper'

RSpec.describe ContributionQueries, type: :model do
  describe '#ordered_feeable_contribution_balances' do
    let(:receiver) { create(:cause) }
    let(:contribution) { create(:contribution, receiver:) }

    context 'when the receiver is differente' do
      let(:contribution_balance1) { create(:contribution_balance, :with_paid_status, fees_balance_cents: 5) }
      let(:contribution_balance2) { create(:contribution_balance, :with_paid_status, fees_balance_cents: 15) }
      let(:contribution_balance3) { create(:contribution_balance, :with_paid_status, fees_balance_cents: 25) }

      it 'returns no contributions' do
        expect(described_class.new(contribution:).ordered_feeable_contribution_balances)
          .to eq []
      end
    end

    context 'when the receiver is the same' do
      let!(:contribution_balance1) do
        create(:contribution_balance,
               contribution: create(:contribution, receiver: contribution.receiver,
                                                   person_payment: create(:person_payment, status: :paid)),
               fees_balance_cents: 5)
      end
      let!(:contribution_balance2) do
        create(:contribution_balance,
               contribution: create(:contribution, receiver: contribution.receiver,
                                                   person_payment: create(:person_payment, status: :paid)),
               fees_balance_cents: 15)
      end
      let!(:contribution_balance3) do
        create(:contribution_balance,
               contribution: create(:contribution, receiver: contribution.receiver,
                                                   person_payment: create(:person_payment, status: :paid)),
               fees_balance_cents: 25)
      end

      it 'returns the contribution balances paid with fees balance ordered by fees balance' do
        expect(described_class.new(contribution:).ordered_feeable_contribution_balances)
          .to eq [contribution_balance1, contribution_balance2, contribution_balance3]
      end
    end
  end
end
