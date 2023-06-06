require 'rails_helper'

RSpec.describe ::Jwt::Auth::Issuer do
  let(:authenticatable) { create(:user_manager) }

  describe '.call' do
    subject(:method_call) { described_class.call(authenticatable) }

    it 'returns an access token and refresh token' do
      access_token, refresh_token = method_call

      expect(access_token).to be_a String
      expect(refresh_token).to be_a RefreshToken
    end
  end
end
