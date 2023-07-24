require 'rails_helper'

RSpec.describe Givings::Impact::NonProfitImpactCalculator, type: :service do
  subject(:service) { described_class.new(non_profit:, value:, currency:) }

  let(:non_profit) { create(:non_profit) }
  let(:value) { 20 }
  let(:currency) { :usd }

  before do
    create(:non_profit_impact, usd_cents_to_one_impact_unit: 15,
                               non_profit:, start_date: 1.year.ago, end_date: 1.year.from_now)
  end

  describe '#impact' do
    it 'calculates the correct value for impact' do
      expect(service.impact).to eq 133.33
    end
  end

  describe '#rounded_impact' do
    it 'rounds the impact to nearest' do
      expect(service.rounded_impact).to eq 133
    end
  end

  describe '#formatted_impact' do
    it 'returns the formatted impact' do
      expect(service.formatted_impact).to eq(['4 months and 13 days', 'of days of water for', '1 donor'])
    end
  end
end
