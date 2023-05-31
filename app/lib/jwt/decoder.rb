# frozen_string_literal: true

module Jwt
  class Decoder < Jwt::Base
    def self.decode(token, key = HMAC_SECRET_KEY, algorithm = DEFAULT_ALGORITHM)
      payload = JWT.decode(token, key, true, { algorithm: })

      raise ::Jwt::Errors::ExpiredSignature if expired?(payload)

      payload
    end

    def self.expired?(payload)
      payload.last['exp'] < Time.zone.now.to_i
    end
  end
end
