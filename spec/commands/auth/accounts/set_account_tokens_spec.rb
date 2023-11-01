# frozen_string_literal: true

require 'rails_helper'

describe Auth::Accounts::SetAccountTokens do
  let(:command) { described_class.call(id_token: 'eyJhbGciOiJSUzI1NiIsIm', provider: 'google_oauth2') }

  describe '.call' do
    include_context('when mocking a request') { let(:cassette_name) { 'google_api_url' } }

    it 'returns successs' do
      expect(command).to be_success
    end

    it 'returns the access and refresh tokens' do
      expect(command.result).to include(:access_token, :refresh_token)
    end
  end
end
