require 'rails_helper'

RSpec.describe Service::Contributions::FeesLabelingService, type: :service do
  before do
    create(:ribon_config, contribution_fee_percentage: 20, minimum_contribution_chargeable_fee_cents: 10)
  end

  describe '#spread_fee_to_payers' do
    let(:person_payment) { create(:person_payment, usd_value_cents: 1000, status: :paid) }
    let(:contribution) { create(:contribution, person_payment:) }
    let!(:contribution_balance1) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 50)
    end
    let!(:contribution_balance2) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 30)
    end
    let!(:contribution_balance3) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 20)
    end

    it 'creates a fee for each feeable contribution balance' do
      fee_service = described_class.new(contribution:)

      expect { fee_service.spread_fee_to_payers }.to change(ContributionFee, :count).by(3)
    end

    it 'generates all the contribution fees' do
      fee_service = described_class.new(contribution:)

      fee_service.spread_fee_to_payers

      expect(ContributionFee.sum(:fee_cents)).to eq(100)
    end

    it 'updates the fees balance of each affected contribution balance' do
      fee_service = described_class.new(contribution:)

      fee_service.spread_fee_to_payers

      expect(contribution_balance1.reload.fees_balance_cents).to eq(0)
      expect(contribution_balance2.reload.fees_balance_cents).to eq(0)
      expect(contribution_balance3.reload.fees_balance_cents).to eq(0)
    end
  end

  context 'when there is a minimum fee' do
    let(:person_payment) { create(:person_payment, usd_value_cents: 1000, status: :paid) }
    let(:contribution) { create(:contribution, person_payment:) }

    # 4.5454
    let!(:contribution_balance1) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 5)
    end
    # 13.6363
    let!(:contribution_balance2) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 15)
    end
    # 27.2727
    let!(:contribution_balance3) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 30)
    end
    # 54.5454
    let!(:contribution_balance4) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment, status: :paid)),
             fees_balance_cents: 60)
    end

    it 'stops spreading the fee when a contribution balance reaches the minimum fee' do
      fee_service = described_class.new(contribution:)

      fee_service.spread_fee_to_payers

      expect(ContributionFee.sum(:fee_cents)).to eq(100)
      expect(contribution_balance1.reload.fees_balance_cents).to eq(0)
      expect(contribution_balance2.reload.fees_balance_cents).to eq(1)
      expect(contribution_balance3.reload.fees_balance_cents).to eq(2)
      expect(contribution_balance4.reload.fees_balance_cents).to eq(7)
    end
  end
end
