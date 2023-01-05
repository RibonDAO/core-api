require 'rails_helper'

RSpec.describe Service::Integrations::ImpactTrend, type: :service do
  subject(:impact_trend_service) { described_class.new(start_date:, end_date:, integration:) }

  before do
    allow(Service::Integrations::Impact).to receive(:new).and_return(previous_impact_service)
    allow(Service::Integrations::Impact)
      .to receive(:new).with(integration:, start_date:, end_date:).and_return(impact_service)
  end

  let(:impact_service) do
    instance_double(Service::Integrations::Impact, {
                      total_donations: 10,
                      total_donors: 6,
                      total_new_donors: 2,
                      total_donors_recurrent: 4,
                      impact_per_non_profit: [],
                      donations_per_non_profit: [],
                      donors_per_non_profit: []
                    })
  end
  let(:previous_impact_service) do
    instance_double(Service::Integrations::Impact, {
                      total_donations: 5,
                      total_donors: 3,
                      total_new_donors: 2,
                      total_donors_recurrent: 4,
                      impact_per_non_profit: [],
                      donations_per_non_profit: [],
                      donors_per_non_profit: []
                    })
  end
  let(:integration) { build(:integration) }
  let(:start_date) { 3.days.ago }
  let(:end_date) { 1.day.ago }

  describe '#formatted_impact' do
    it 'returns all the stats in a hash' do
      expect(impact_trend_service.formatted_impact)
        .to eq({
                 total_donations: 10, previous_total_donations: 5, total_donors: 6, previous_total_donors: 3,
                 impact_per_non_profit: [], donations_per_non_profit: [], donors_per_non_profit: [],
                 total_donations_balance: 5, total_donors_balance: 3,
                 total_donations_trend: 100.0, total_donors_trend: 100.0, previous_impact_per_non_profit: [],
                 previous_donations_per_non_profit: [], previous_donors_per_non_profit: [],
                 total_new_donors: 2, total_donors_recurrent: 4
               })
    end
  end
end
