# frozen_string_literal: true

require 'rails_helper'

describe Contributions::IncreaseContributionBalanceFee do
  subject(:command) { described_class.call(contribution_balance:, fee_cents:) }

  let(:fees_balance_cents) { 10 }
  let(:contribution_balance) { create(:contribution_balance, fees_balance_cents:) }
  let(:fee_cents) { 1 }

  describe '#call' do
    it 'increases the fees_balance_cents' do
      command
      expect(contribution_balance.reload.fees_balance_cents).to eq(11)
    end
  end
end
