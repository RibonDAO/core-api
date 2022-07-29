# frozen_string_literal: true

module Integrations
  class CreateIntegration < ApplicationCommand
    prepend SimpleCommand
    include Web3

    attr_reader :name, :status

    def initialize(name:, status:)
      @name   = name
      @status = status
    end

    def call
      with_exception_handle do
        integration = Integration.create!(name:, status:, unique_address:)
        IntegrationWallet.create!(encrypted_wallet.merge!(integration:))

        integration
      end
    end

    private

    def unique_address
      SecureRandom.uuid
    end

    def encrypted_wallet
      public_key, private_key = Providers::Keys.generate_keypair

      encrypted_key = Utils::Cipher.encrypt(private_key)

      {
        public_key:,
        encrypted_private_key: encode(encrypted_key.cipher_text),
        private_key_iv: encode(encrypted_key.iv)
      }
    end

    def encode(text)
      Base64.strict_encode64(text)
    end
  end
end
