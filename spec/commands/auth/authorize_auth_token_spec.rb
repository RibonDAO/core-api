# frozen_string_literal: true

require 'rails_helper'

describe Auth::AuthorizeAuthToken do
  describe '.call' do
    subject(:command) { described_class.call(auth_token:, authenticatable:) }

    let(:authenticatable) { create(:big_donor) }
    let(:auth_token) { 'auth_token' }
    let(:email_link_service) { instance_double(Auth::EmailLinkService, valid_auth_token?: valid_auth_token) }

    before do
      allow(Auth::EmailLinkService).to receive(:new).and_return(email_link_service)
      allow(Jwt::Auth::Issuer).to receive(:call).and_return(%w[access_token refresh_token])
    end

    context 'when the token is valid' do
      let(:valid_auth_token) { true }

      it 'return success' do
        expect(command).to be_success
      end

      it 'return an access token and refresh token for the authenticatable' do
        expect(command.result).to eq({ access_token: 'access_token',
                                       refresh_token: 'refresh_token' })
      end
    end

    context 'when the token is not valid' do
      let(:valid_auth_token) { false }

      it 'returns failure' do
        expect(command).to be_failure
      end
    end
  end
end
