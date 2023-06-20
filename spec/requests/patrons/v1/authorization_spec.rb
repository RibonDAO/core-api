require 'rails_helper'

RSpec.describe 'Patrons::V1::Authorization', type: :request do
  describe 'GET /send_authentication_email' do
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
end
