require 'rails_helper'

RSpec.describe ::Jwt::Encoder do
  describe '.encode' do
    subject(:method_call) { described_class.encode(payload, expiration, key, algorithm) }

    let(:payload)   { { 'foo' => 'bar' } }
    let(:key)       { SecureRandom.hex(32) }
    let(:expiration) { 30.minutes.from_now.to_i }
    let(:algorithm) { 'HS256' }

    it 'returns a JWT token' do
      expect(method_call).to be_a String
    end
  end
end
