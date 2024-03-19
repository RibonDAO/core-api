module Signatures
  class Sha256
    SIGNATURE_KEY = RibonCoreApi.config[:sha256][:signature_key]

    def self.sign(data)
      ::Digest::SHA256.hexdigest("#{data}#{SIGNATURE_KEY}")
    end

    def self.verify(data, signature)
      sign(data) == signature
    end
  end
end