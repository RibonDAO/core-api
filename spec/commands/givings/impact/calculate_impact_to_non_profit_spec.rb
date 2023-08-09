# frozen_string_literal: true

require 'rails_helper'

describe Givings::Impact::CalculateImpactToNonProfit do
  subject(:command) { described_class.call(non_profit:, value:, currency:) }

  describe '.call' do
    let(:value) { 10 }
    let(:non_profit) { create(:non_profit, :with_impact) }
    let(:currency) { :usd }

    it 'returns the impact, rounded impact and formatted impact' do
      expect(command.result).to eq({ impact: 100, rounded_impact: 100,
                                     formatted_impact: ['100', '1 day of water for', '1 donor'],
                                     measurement_unit: 'quantity_without_decimals' })
    end
  end
end
