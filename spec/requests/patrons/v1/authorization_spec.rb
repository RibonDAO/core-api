require 'rails_helper'

RSpec.describe 'Patrons::V1::Authorization', type: :request do
  describe 'POST /send_authentication_email' do
    subject(:request) { post '/patrons/v1/auth/send_authentication_email', params: }

    let(:patron) { create(:big_donor, email: 'patron@ribon.io') }
    let(:params) { { email: patron.email } }
    let(:command) { command_double(klass: Auth::SendAuthenticationLink, success: true) }

    before do
      allow(Auth::SendAuthenticationLink).to receive(:call).and_return(command)
      request
    end

    it 'calls the send authentication link command with right params' do
      expect(Auth::SendAuthenticationLink).to have_received(:call).with(
        authenticatable: patron
      )
    end

    context 'when the send authentication link command succeeds' do
      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the send authentication link command fails' do
      let(:command) { command_double(klass: Auth::SendAuthenticationLink, success: false) }

      it 'returns status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST /authorize_from_email_link' do
    subject(:request) { post '/patrons/v1/auth/authorize_from_email_link', params: }

    let(:patron) { create(:big_donor) }
    let(:params) { { auth_token: 'auth_token', id: patron.id } }
    let(:command) do
      command_double(klass: Auth::AuthorizeAuthToken,
                     success: true, result:)
    end
    let(:result) do
      { access_token: 'access_token',
        refresh_token: OpenStruct.new({ token: 'refresh_token' }) }
    end

    before do
      allow(Auth::AuthorizeAuthToken).to receive(:call).and_return(command)
      request
    end

    it 'calls the send authorize command with right params' do
      expect(Auth::AuthorizeAuthToken).to have_received(:call).with(
        authenticatable: patron, auth_token: 'auth_token'
      )
    end

    context 'when the send authentication link command succeeds' do
      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the access token and refresh token on headers' do
        expect(response.headers['access-token']).to eq('access_token')
        expect(response.headers['refresh-token']).to eq('refresh_token')
      end
    end

    context 'when the send authentication link command fails' do
      let(:command) { command_double(klass: Auth::AuthorizeAuthToken, success: false) }

      it 'returns status unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
