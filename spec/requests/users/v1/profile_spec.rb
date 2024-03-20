require 'rails_helper'

RSpec.describe 'Users::V1::Profile', type: :request do
  describe 'GET /users/v1/profile without headers' do
    let(:request) { get '/users/v1/profile' }

    it 'returns http status unauthorized' do
      request

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /users/v1/profile' do
    include_context 'when making a user request' do
      let(:request) { get '/users/v1/profile', headers: }
    end
    let(:user) { account.user }

    before do
      create(:user_profile, user:)
    end

    it 'returns http status ok' do
      request

      expect(response).to have_http_status(:ok)
    end

    it 'returns the user profile' do
      request
      expect_response_to_have_keys %w[name photo user]
    end
  end
end
