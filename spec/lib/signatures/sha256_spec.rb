require 'rails_helper'

RSpec.describe Signatures::Sha256 do
  let(:data) { 'test' }
  let(:signature) { 'bcbd89709cc787326915ec6b335b11942cc5b8dfb636def12ea1276f35254a47' }

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
