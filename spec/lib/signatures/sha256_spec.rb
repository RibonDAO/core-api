require 'rails_helper'

RSpec.describe Signatures::Sha256 do
  let(:data) { 'test' }
  let(:signature) { '98483c6eb40b6c31a448c22a66ded3b5e5e8d5119cac8327b655c8b5c4836489' }

  before do
    allow(RibonCoreApi).to receive(:config).and_return(
      sha256: {
        signature_key: 'key'
      }
    )
  end

  describe '.sign' do
    it 'returns a sha256 signature' do
      expect(described_class.sign(data)).to eq signature
    end
  end

  describe '.verify' do
    it 'returns true if the signature is valid' do
      expect(described_class.verify(data, signature)).to eq true
    end

    it 'returns false if the signature is invalid' do
      expect(described_class.verify(data, 'invalid')).to eq false
    end
  end
end
