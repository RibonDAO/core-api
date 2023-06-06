require 'rails_helper'

RSpec.describe ::Jwt::Auth::Decoder do
  let(:access_token) { Jwt::Auth::Encoder.call(authenticatable).first }
  let(:authenticatable) { create(:user_manager) }

  describe '.call' do
    subject(:method_call) { described_class.decode!(access_token) }

    it 'returns the decoded token keys' do
      expect(method_call.keys).to match_array %i[jti exp iat authenticatable_id authenticatable_type]
    end

    it 'returns the authenticatable data' do
      expect(method_call[:authenticatable_id]).to eq authenticatable.id
      expect(method_call[:authenticatable_type]).to eq authenticatable.class.name
    end
  end
end
