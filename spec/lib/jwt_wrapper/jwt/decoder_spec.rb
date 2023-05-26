require 'rails_helper'

RSpec.describe JwtWrapper::Jwt::Decoder do
  describe '.decode' do
    subject(:method_call) { described_class.decode(token, key, algorithm) }

    let(:payload)   { { 'foo' => 'bar' } }
    let(:key)       { 'secret' }
    let(:algorithm) { 'HS256' }
    let(:token)     { JwtWrapper::Jwt::Encoder.encode(payload, key, algorithm) }

    it 'returns a hash' do
      expect(method_call).to be_a Array
    end

    it 'returns the correct payload' do
      expect(method_call[0]).to eq payload
    end
  end
end
