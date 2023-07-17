require 'rails_helper'

RSpec.describe Service::Contributions::DirectImpactService, type: :service do
  subject(:service) { described_class.new(contribution:) }

  let(:cause) { create(:cause) }
  let(:non_profit) { create(:non_profit, :with_impact, cause:) }
  let(:person_payment) { create(:person_payment, usd_value_cents: 1_000) }
  let(:contribution) { create(:contribution, receiver: cause, person_payment:) }
  let(:donation) { create(:donation, value: 10, non_profit:) }

  before do
    create(:ribon_config, contribution_fee_percentage: 20, minimum_contribution_chargeable_fee_cents: 10)
    create_list(:donation_contribution, 3, contribution:, donation:)
  end

  describe '#impact' do
    it 'returns the necessary keys' do
      expect(service.impact.first.keys)
        .to match_array(%i[non_profit formatted_impact total_amount_donated])
    end
  end

  describe '#direct_impact_for' do
    it 'returns the total amount donated for the non profit' do
      expect(service.direct_impact_for(non_profit)[:total_amount_donated]).to eq('$0.30')
    end

    it 'returns the formatted impact for the non profit' do
      expect(service.direct_impact_for(non_profit)[:formatted_impact])
        .to eq(['3', '1 day of water for', '1 donor'])
    end

    it 'returns the non profit' do
      expect(service.direct_impact_for(non_profit)[:non_profit]).to eq(non_profit)
    end
  end
end
