# frozen_string_literal: true

require 'rails_helper'

describe Auth::Accounts::SetAccountTokens do
  include_context('when mocking a request') { let(:cassette_name) { 'google_api_url' } }

  before do
    allow(JWT).to receive(:decode).and_return([OpenStruct.new({ email: 'user1@ribon.io' })])
  end

  %w[google_oauth2 google_oauth2_access apple].each do |provider|
    context "when #{provider}" do
      let(:token) { 'eyJhbGciOiJSUzI1NiIsIm' }
      let(:command) { described_class.call(token:, provider:, current_email: authenticatable.email) }
      let(:authenticatable) { create(:account) }

      it 'returns successs' do
        expect(command).to be_success
      end

      it 'returns the access and refresh tokens and the user' do
        access_token, refresh_token, user = command.result
        expect(access_token).to be_an_instance_of(String)
        expect(refresh_token).to be_a RefreshToken
        expect(user).to be_a User
      end

      context 'when email and current email dont match' do
        let(:command_wrong_email) do
          described_class.call(token:, provider:, current_email: 'test1@email.com')
        end

        it 'returns a error message' do
          unless provider == 'google_oauth2'
            expect(command_wrong_email.errors[:message]).to eq(['Email does not match'])
          end
        end
      end
    end
  end
end
