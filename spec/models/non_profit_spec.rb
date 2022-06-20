require 'rails_helper'

RSpec.describe NonProfit, type: :model do
  describe '.validations' do
    subject { build(:non_profit) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:wallet_address) }
    it { is_expected.to validate_presence_of(:impact_description) }
  end

  describe '#impact_for' do
    subject(:non_profit) { build(:non_profit) }

    let(:date) { Date.parse('2022-02-02') }
    let(:non_profit_impact1) do
      create(:non_profit_impact, non_profit:, start_date: '2022-02-01', end_date: '2022-03-01')
    end
    let(:non_profit_impact2) do
      create(:non_profit_impact, non_profit:, start_date: '2021-06-01', end_date: '2021-09-01')
    end

    before do
      non_profit_impact1
      non_profit_impact2
    end

    it 'returns the non_profit_impact that includes the passed date' do
      expect(non_profit.impact_for(date:)).to eq non_profit_impact1
    end
  end

  describe '#impact_by_ticket' do
    subject(:non_profit) { build(:non_profit) }

    let(:date) { Date.parse('2022-02-02') }
    let(:non_profit_impact) do
      create(:non_profit_impact, non_profit:,
                                 start_date: '2022-02-01', end_date: '2022-03-01',
                                 usd_cents_to_one_impact_unit: 10)
    end

    before do
      create(:ribon_config, default_ticket_value: 100)
      non_profit_impact
    end

    it 'returns the impact by ticket' do
      expect(non_profit.impact_by_ticket(date:)).to eq 10
    end
  end
end
