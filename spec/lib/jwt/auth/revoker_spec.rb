require 'rails_helper'

RSpec.describe ::Jwt::Auth::Revoker do
  let(:authenticatable) { create(:user_manager) }
  let(:access_token) { Jwt::Auth::Issuer.call(authenticatable).first }
  let(:decoded_token) { Jwt::Auth::Decoder.decode!(access_token) }
  let(:jti) { decoded_token[:jti] }

  describe '.call' do
    subject(:method_call) { described_class.revoke(decoded_token:, authenticatable:) }

    it 'adds the token to the blocklist' do
      method_call

      expect(Jwt::Auth::Blocklister.blocklisted?(jti:)).to be_truthy
    end

    it 'removes the token from the allowlist' do
      method_call

      expect(Jwt::Auth::Allowlister.allowlisted?(jti: decoded_token[:jti])).to be_falsey
    end
  end
end
