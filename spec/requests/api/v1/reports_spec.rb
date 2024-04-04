require 'rails_helper'

RSpec.describe 'Api::V1::ReportsController', :report, type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/reports' }

    let(:report) { create(:report) }

    it 'returns a successfull response' do
      request

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/reports/#{report.id}" }

    let(:report) { create(:report) }

    it 'returns a single report' do
      request

      expect_response_to_have_keys(%w[id name link active])
    end
  end
end
