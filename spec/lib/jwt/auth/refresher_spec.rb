require 'rails_helper'

RSpec.describe ::Jwt::Auth::Refresher do
  let(:authenticatable) { create(:user_manager) }
  let(:access_refresh_token) { Jwt::Auth::Issuer.call(authenticatable) }
  let(:access_token) { access_refresh_token.first }
  let(:refresh_token) { access_refresh_token.last.token }
  let(:decoded_token) { Jwt::Auth::Decoder.decode!(access_token) }

  describe '.call' do
    subject(:method_call) { described_class.refresh!(refresh_token:, decoded_token:, authenticatable:) }

    it 'returns a new access token and refresh token' do
      access_token, refresh_token = method_call

      expect(access_token).to be_a String
      expect(refresh_token).to be_a RefreshToken
    end

    it 'blocklists the previous access token' do
      method_call

      expect(Jwt::Auth::Blocklister.blocklisted?(jti: decoded_token[:jti])).to be_truthy
      expect(Jwt::Auth::Allowlister.allowlisted?(jti: decoded_token[:jti])).to be_falsey
    end

    it 'destroys the previous refresh token' do
      method_call

      expect(RefreshToken.find_by_token(refresh_token)).to be_nil
    end
  end
end
