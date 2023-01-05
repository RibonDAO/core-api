require 'rails_helper'

RSpec.describe 'Api::V1::Integrations::Impacts', type: :request do
  describe 'GET /index' do
    subject(:request) { get "/api/v1/integrations/#{id}/impacts" }

    let(:id) { create(:integration).unique_address }

    let(:impact) do
      { total_donations: 10, total_donors: 6,
        impact_per_non_profit: [{ non_profit:, impact: 350 }],
        donations_per_non_profit: [{ non_profit:, donations: 5 }],
        donors_per_non_profit: [{ non_profit:, donors: 3 }],
        previous_total_donations: 5, previous_total_donors: 3,
        previous_impact_per_non_profit: [],
        previous_donations_per_non_profit: [],
        previous_donors_per_non_profit: [],
        total_donations_balance: 5,
        total_donors_balance: 2, total_donations_trend: 100.0, total_donors_trend: 100.0,
        total_new_donors: 2, total_donors_recurrent: 4 }
    end
    let(:impact_service_instance) { instance_double(Service::Integrations::ImpactTrend, formatted_impact: impact) }
    let(:non_profit) { build(:non_profit) }

    before do
      allow(Service::Integrations::ImpactTrend).to receive(:new).and_return(impact_service_instance)
    end

    it 'returns the required keys' do
      request

      expect_response_to_have_keys(%w[total_donations total_donors impact_per_non_profit
                                      previous_impact_per_non_profit previous_total_donations
                                      previous_total_donors total_donations_balance total_donations_trend
                                      total_donors_balance total_donors_trend donations_per_non_profit
                                      donors_per_non_profit previous_donations_per_non_profit
                                      previous_donors_per_non_profit total_new_donors total_donors_recurrent])
    end
  end
end
