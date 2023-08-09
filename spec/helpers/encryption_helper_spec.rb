# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EncryptionHelper do
  describe '.encrytp_string' do
    let(:key) { RibonCoreApi.config[:web3][:node_url][:encryption_key] }
    let(:iv) { RibonCoreApi.config[:web3][:node_url][:encryption_iv] }
    let(:string) { 'https://polygon-mumbai.g.alchemy.com/v2/iwJOj0NGGqgpYpyCJxt3dZzu9wOMACg_' }
    let(:encrypted_string) do
      'nfvh2JWBaXWqY6eigowvPVk/' \
        'JuKnFkEmlZNraoiYZg6fQ07yDYfOSq9oQs/' \
        'CHLMYI0G67+qvGkv6DI08fp63AJGp3siqNvXujh1N6jK0nnA='
    end

    it 'encrypt a string' do
      result = described_class.encrypt_string(string, key, iv)

      expect(result).to eq(encrypted_string)
    end
  end
end
