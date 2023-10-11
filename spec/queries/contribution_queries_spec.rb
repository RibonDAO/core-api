require 'rails_helper'

RSpec.describe ContributionQueries, type: :model do
  describe '#ordered_feeable_contribution_balances' do
    let(:receiver) { create(:cause) }
    let(:contribution) do
      create(:contribution, receiver:, person_payment: create(:person_payment,
                                                              :with_payment_in_blockchain,
                                                              status: :paid))
    end

    context 'when the receiver is different' do
      let(:contribution_balance1) do
        create(:contribution_balance, :with_paid_status, fees_balance_cents: 5,
                                                         person_payment: create(:person_payment,
                                                                                :with_payment_in_blockchain,
                                                                                status: :paid))
      end
      let(:contribution_balance2) do
        create(:contribution_balance, :with_paid_status,
               fees_balance_cents: 15,
               person_payment: create(:person_payment,
                                      :with_payment_in_blockchain,
                                      status: :paid))
      end
      let(:contribution_balance3) do
        create(:contribution_balance, :with_paid_status,
               fees_balance_cents: 25,
               person_payment: create(:person_payment,
                                      :with_payment_in_blockchain,
                                      status: :paid))
      end

      it 'returns no contributions' do
        expect(described_class.new(contribution:).ordered_feeable_contribution_balances)
          .to eq []
      end
    end

    # Adicionar condicão de tempo, as transações só serão validas quando acontecerem antes
    # succeeded at na blockchain
    xit context 'when the receiver is the same' do
      let!(:contribution_balance1) do
        create(:contribution_balance,
               contribution: create(:contribution,
                                    receiver: contribution.receiver,
                                    person_payment: create(:person_payment,
                                                           :with_payment_in_blockchain,
                                                           status: :paid)),
               fees_balance_cents: 5)
      end
      let!(:contribution_balance2) do
        create(:contribution_balance,
               contribution: create(:contribution, receiver: contribution.receiver,
                                                   person_payment: create(:person_payment,
                                                                          :with_payment_in_blockchain,
                                                                          status: :paid)),
               fees_balance_cents: 15)
      end
      let!(:contribution_balance3) do
        create(:contribution_balance,
               contribution: create(:contribution, receiver: contribution.receiver,
                                                   person_payment: create(:person_payment,
                                                                          :with_payment_in_blockchain,
                                                                          status: :paid)),
               fees_balance_cents: 25)
      end

      it 'returns the contribution balances paid with fees balance ordered by fees balance' do
        expect(described_class.new(contribution:).ordered_feeable_contribution_balances)
          .to eq [contribution_balance1, contribution_balance2, contribution_balance3]
      end
    end
  end
end
