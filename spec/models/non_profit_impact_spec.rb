require 'rails_helper'

RSpec.describe NonProfitImpact, type: :model do
  describe '.validations' do
    subject { build(:non_profit_impact) }

    it { is_expected.to belong_to(:non_profit) }
    it { is_expected.to validate_presence_of(:usd_cents_to_one_impact_unit) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
  end

  describe '#impact_by_ticket' do
    subject(:non_profit_impact) { build(:non_profit_impact, usd_cents_to_one_impact_unit: 100) }

    before do
      create(:ribon_config, default_ticket_value: 1000)
    end

    it 'returns the default ticket value divided by the usd cents to one impact' do
      expect(non_profit_impact.impact_by_ticket).to eq 10
    end
  end
end
