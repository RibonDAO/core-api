# frozen_string_literal: true

require 'rails_helper'

describe Contributions::IncreaseContributionBalanceFee do
  subject(:command) do
    described_class.call(contribution_balance:, fee_cents:, payer_contribution_increased_amount_cents:)
  end

  let(:fees_balance_cents) { 10 }
  let(:payer_contribution_increased_amount_cents) { 10 }
  let(:contribution_increased_amount_cents) { 10 }
  let(:contribution_balance) do
    create(:contribution_balance, fees_balance_cents:, contribution_increased_amount_cents:)
  end
  let(:fee_cents) { 1 }

  describe '#call' do
    it 'increases the fees_balance_cents' do
      command
      expect(contribution_balance.reload.fees_balance_cents).to eq(11)
    end

    it 'decrease the contribution_increased_amount_cents' do
      command
      expect(contribution_balance.reload.contribution_increased_amount_cents).to eq(0)
    end
  end
end
