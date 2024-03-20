require 'rails_helper'

RSpec.describe 'Api::V1::Configs::RibonConfig', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/configs/settings' }

    before do
      create(:ribon_config)
    end

    it 'returns a list of integrations' do
      request

      expect_response_collection_to_have_keys(%w[id updated_at default_ticket_value ribon_club_fee_percentage])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/api/v1/configs/settings/#{ribon_config.id}", params: }

    let(:ribon_config) { create(:ribon_config) }
    let(:params) { { default_ticket_value: '100.4' } }

    it 'updates the ribon config' do
      request

      expect(ribon_config.reload.default_ticket_value).to eq(100.4)
    end
  end
end
