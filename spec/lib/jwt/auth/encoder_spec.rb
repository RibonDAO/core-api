require 'rails_helper'

RSpec.describe ::Jwt::Auth::Encoder do
  let(:authenticatable) { create(:user_manager) }

  describe '.call' do
    subject(:method_call) { described_class.call(authenticatable) }

    it 'returns an access token, jti and exp' do
      access_token, jti, exp = method_call

      expect(access_token).to be_a String
      expect(jti).to be_a String
      expect(exp).to be_a Integer
    end
  end
end
