require 'rails_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/tasks' }

    let(:task) { create(:task) }

    it 'returns a successful response' do
      request

      expect(response).to have_http_status(:ok)
    end
  end
end
