# frozen_string_literal: true

module EncryptionHelper
  require 'openssl'

  def self.encrypt_string(string, key, key_iv)
    return unless key

    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = key
    cipher.iv = key_iv

    encrypted = cipher.update(string) + cipher.final
    Base64.encode64(encrypted).delete("\n")
  end
end
