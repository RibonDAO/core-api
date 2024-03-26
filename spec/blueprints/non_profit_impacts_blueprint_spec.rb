require 'rails_helper'

RSpec.describe NonProfitImpactsBlueprint, type: :blueprint do
  describe 'When non profit impact is bigger than ticket value' do
    let(:non_profit) { create(:non_profit) }
    let(:non_profit_impact) do
      create(:non_profit_impact, non_profit:, usd_cents_to_one_impact_unit: 100)
    end
    let(:non_profit_impacts_blueprint) { described_class.render(non_profit_impact) }

    before do
      create(:ribon_config, default_ticket_value: 10)
    end

    it 'calculates minimum number of tickets' do
      expect(JSON.parse(non_profit_impacts_blueprint)['minimum_number_of_tickets']).to be(10)
    end
  end

  describe 'When non profit impact is lower than ticket value' do
    let(:non_profit) { create(:non_profit) }
    let(:non_profit_impact) do
      create(:non_profit_impact, non_profit:, usd_cents_to_one_impact_unit: 10)
    end
    let(:non_profit_impacts_blueprint) { described_class.render(non_profit_impact) }

    before do
      create(:ribon_config, default_ticket_value: 100)
    end

    it 'calculates minimum number of tickets' do
      expect(JSON.parse(non_profit_impacts_blueprint)['minimum_number_of_tickets']).to be(1)
    end
  end
end
