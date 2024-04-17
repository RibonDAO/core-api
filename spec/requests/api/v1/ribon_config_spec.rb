require 'rails_helper'

RSpec.describe 'Api::V1::Configs::RibonConfig', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/configs/settings' }

    before do
      create(:ribon_config)
    end

    it 'returns the ribon configs' do
      request

      expect_response_to_have_keys(%w[id updated_at default_ticket_value ribon_club_fee_percentage
                                      minimum_version_required])
    end
  end
end
