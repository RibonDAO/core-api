# frozen_string_literal: true

require 'rails_helper'

describe Auth::Accounts::SetAccountTokens do
  include_context('when mocking a request') { let(:cassette_name) { 'google_api_url' } }

  describe 'google_oauth2' do
    let(:command) { described_class.call(token: 'eyJhbGciOiJSUzI1NiIsIm', provider: 'google_oauth2') }

    it 'returns successs' do
      expect(command).to be_success
    end

    it 'returns the access and refresh tokens' do
      expect(command.result).to include(:access_token, :refresh_token)
    end
  end

  describe 'google_oauth2_access' do
    let(:command) { described_class.call(token: 'eyJhbGciOiJSUzI1NiIsIm', provider: 'google_oauth2_access') }

    it 'returns successs' do
      expect(command).to be_success
    end

    it 'returns the access and refresh tokens' do
      expect(command.result).to include(:access_token, :refresh_token)
    end
  end

  describe 'apple' do
    let(:command) { described_class.call(token: 'eyJhbGciOiJSUzI1NiIsIm', provider: 'apple') }

    before do
      allow(JWT).to receive(:decode).and_return([OpenStruct.new({ email: 'test@ribon.io' })])
    end

    it 'returns successs' do
      expect(command).to be_success
    end

    it 'returns the access and refresh tokens' do
      expect(command.result).to include(:access_token, :refresh_token)
    end
  end
end
