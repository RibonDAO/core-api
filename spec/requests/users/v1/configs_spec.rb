require 'rails_helper'

RSpec.describe 'Users::V1::Configs', type: :request do
  describe 'PUT /users/v1/configs without headers' do
    subject(:request) { post '/users/v1/configs' }

    it 'returns http status unauthorized' do
      request

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PUT /users/v1/configs' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/configs', headers:, params: }
    end

    let(:user) { account.user }
    let(:params) do
      { allowed_email_marketing: true }
    end

    it 'returns http status ok' do
      request

      expect(response).to have_http_status(:ok)
    end

    context 'when there is an user config' do
      before do
        create(:user_config, user:, allowed_email_marketing: false)
        request
      end

      it 'updates the user config' do
        expect(user.user_config.reload.allowed_email_marketing).to be_truthy
      end
    end

    context 'when there is no user config' do
      it 'creates an user config' do
        expect { request }.to change(UserConfig, :count).by(1)
      end

      it 'sets the user config according to the params' do
        request

        expect(user.user_config.reload.allowed_email_marketing).to be_truthy
      end
    end

    context 'when the params are invalid' do
      let(:params) do
        { allowed_email_marketing: nil }
      end

      it 'returns http status unprocessable_entity' do
        request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the errors' do
        request

        expect(response_json).to eq({ 'allowed_email_marketing' => ['is not included in the list'] })
      end
    end
  end
end
