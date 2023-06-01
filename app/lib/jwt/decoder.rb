# frozen_string_literal: true

module Jwt
  class Decoder < Jwt::Base
    def self.decode(token, key = HMAC_SECRET_KEY, algorithm = DEFAULT_ALGORITHM)
      raise Errors::MissingToken if token.blank?

      JWT.decode(token, key, true, { algorithm: })
    rescue JWT::ExpiredSignature
      raise Errors::ExpiredSignature
    end
  end
end
