require 'rails_helper'

RSpec.describe ::Jwt::Decoder do
  describe '.decode' do
    subject(:method_call) { described_class.decode(token:, key:, algorithm:) }

    context 'when token is newer than 30 minutes' do
      let(:payload)   { { 'foo' => 'bar' } }
      let(:key)       { 'secret' }
      let(:algorithm) { 'HS256' }
      let(:exp)       { 30.minutes.from_now.to_i }
      let(:token)     { ::Jwt::Encoder.encode(payload, exp, key, algorithm) }

      it 'returns a hash' do
        expect(method_call).to be_a Array
      end

      it 'returns the correct payload' do
        expect(method_call[0]).to eq strong_params(payload)
      end
    end

    context 'when token is older than 30 minutes' do
      let(:payload)   { { 'foo' => 'bar' } }
      let(:key)       { 'secret' }
      let(:algorithm) { 'HS256' }
      let(:exp)       { -4.hours }
      let(:token)     { ::Jwt::Encoder.encode(payload, exp, key, algorithm) }

      it 'raises an error' do
        expect { method_call }.to raise_error ::Jwt::Errors::ExpiredSignature
      end
    end
  end
end
