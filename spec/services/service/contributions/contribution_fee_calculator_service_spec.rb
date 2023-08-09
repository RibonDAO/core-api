# frozen_string_literal: true

require 'rails_helper'

describe Service::Contributions::ContributionFeeCalculatorService do
  subject(:service) do
    described_class.new(payer_balance:, fee_to_be_paid:,
                        initial_contributions_balance:)
  end

  let(:payer_balance) { create(:contribution_balance, fees_balance_cents: 5000).fees_balance_cents }
  let(:initial_contributions_balance) { 10_000 }
  let(:fee_to_be_paid) { 100 }

  before do
    create(:ribon_config, minimum_contribution_chargeable_fee_cents: 10)
  end

  describe '#proportional_fee' do
    context 'when the fee to be paid is higher then the minimum' do
      it 'calculates the fee based on the total amount and the payer contribution balance' do
        expect(service.proportional_fee).to eq(50)
      end
    end

    context 'when the fee to be paid is less then the minimum' do
      let(:fee_to_be_paid) { 10 }

      it 'returns the minimum fee' do
        expect(service.proportional_fee).to eq(10)
      end
    end
  end

  describe '#increased_value_for' do
    let(:contribution) { create(:contribution, person_payment: create(:person_payment, usd_value_cents: 1000)) }

    it 'returns the percentage of fee paid relative to the contribution value' do
      expect(service.increased_value_for(contribution:)).to eq(500)
    end
  end
end
