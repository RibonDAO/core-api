require 'rails_helper'

RSpec.describe 'Api::V1::Users::Configs', type: :request do
  describe 'PUT /api/v1/users/configs' do
    subject(:request) { post "/api/v1/users/#{user.id}/configs", headers:, params: }

    let(:user) { create(:user) }
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
  end
end
