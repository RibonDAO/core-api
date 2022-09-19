module Web3
  module Utils
    class Cipher
      def self.encrypt(plain_text)
        cipher     = cipher_instance.encrypt
        iv         = cipher.random_iv
        cipher.key = sha256_key

        OpenStruct.new({
                         cipher_text: cipher.update(plain_text) + cipher.final,
                         iv:
                       })
      end

      def self.decrypt(cipher_text, cipher_iv)
        decipher     = cipher_instance.decrypt
        decipher.iv  = cipher_iv
        decipher.key = sha256_key

        OpenStruct.new({
                         plain_text: decipher.update(cipher_text) + decipher.final
                       })
      end

      def self.cipher_instance
        OpenSSL::Cipher.new('aes-256-cbc')
      end

      def self.sha256_key
        ::Digest::SHA256.digest secret_key
      end

      def self.secret_key
        return '' if Rails.env.development?

        RibonCoreApi.config[:openssl][:ribon_secret_openssl_key]
      end
    end
  end
end
