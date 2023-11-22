require 'rails_helper'

RSpec.describe 'Users::V1::Authentication', type: :request do
  describe 'POST /send_authentication_email' do
    
    subject(:request) { post '/users/v1/auth/send_authentication_email', params: }

    let(:user) { create(:user) }
    let(:params) { { email: user.email } }
    let(:command) { command_double(klass: Auth::Accounts::SendAuthenticationEmail, success: true, result:) }

        let(:result) do
      { access_token: 'access_token',
        refresh_token: OpenStruct.new({ token: 'refresh_token' }),
    email: user.email }
    end

    before do
      allow(Auth::Accounts::SendAuthenticationEmail).to receive(:call).and_return(command)
      request
    end

    it 'calls the send authentication link command with right params' do
      expect(Auth::Accounts::SendAuthenticationEmail).to have_received(:call).with(
        email: user.email, id: nil
      )
    end

    context 'when the send authentication link command succeeds' do
      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the user' do
        expect(response_body.email).to eq(user.email)
      end
    end

    context 'when the send authentication link command fails' do
      let(:command) { command_double(klass: Auth::Accounts::SendAuthenticationEmail, success: false) }

      it 'returns status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /authorize_from_auth_token' do
     include_context 'when making a user request' do
    subject(:request) { post '/users/v1/auth/authorize_from_auth_token', params: }

     end
    
    let(:params) { { auth_token: 'auth_token', id: account.id } }
    let(:command) do
      command_double(klass: Auth::Accounts::AuthorizeAuthToken,
                     success: true, result:)
    end
    let(:result) do
      { access_token: 'access_token',
        refresh_token: OpenStruct.new({ token: 'refresh_token' }) }
    end

    before do
      allow(Auth::Accounts::AuthorizeAuthToken).to receive(:call).and_return(command)
      request
    end

    it 'calls the send authorize command with right params' do
      expect(Auth::Accounts::AuthorizeAuthToken).to have_received(:call).with(
        authenticatable: account, auth_token: 'auth_token'
      )
    end

    context 'when the send authentication link command succeeds' do
      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the send authentication link command fails' do
      let(:command) { command_double(klass: Auth::Accounts::AuthorizeAuthToken, success: false) }

      it 'returns status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
