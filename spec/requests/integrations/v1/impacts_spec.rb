require 'rails_helper'

RSpec.describe 'Integrations::V1::Impacts', type: :request do
  describe 'GET /index' do
    include_context('when making an integration request') do
      let(:request) { get '/integrations/v1/impacts', headers: }
    end

    let(:impact) do
      { total_donations: 10, total_donors: 5,
        impact_per_non_profit: [{ non_profit: { name: 'Non Profit 1' }, impact: 350 }],
        donations_per_non_profit: [{ non_profit: { name: 'Non Profit 1' }, donations: 5 }],
        donors_per_non_profit: [{ non_profit: { name: 'Non Profit 1' }, donors: 3 }] }
    end
    let(:impact_service_instance) { instance_double(Integrations::Impact, formatted_impact: impact) }

    before do
      allow(Integrations::Impact).to receive(:new).and_return(impact_service_instance)
    end

    it 'returns the integration impact' do
      request

      expect(response_json.to_json).to eq impact.to_json
    end
  end
end
