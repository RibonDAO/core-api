# frozen_string_literal: true

module JwtWrapper
  module Jwt
    DEFAULT_ALGORITHM   = 'HS256'
    HMAC_SECRET_KEY     = RibonCoreApi.config[:hmac][:secret_key]

    def self.encode(payload, key = HMAC_SECRET_KEY, algorithm = DEFAULT_ALGORITHM)
      Encoder.encode(payload, key, algorithm)
    end

    def self.decode(token, key = HMAC_SECRET_KEY, algorithm = DEFAULT_ALGORITHM)
      Decoder.decode(token, key, algorithm)
    end
  end
end
