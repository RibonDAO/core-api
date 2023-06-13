# frozen_string_literal: true

module Jwt
  class Decoder < Jwt::Base
    def self.decode(token:, key: HMAC_SECRET_KEY, algorithm: DEFAULT_ALGORITHM, custom_options: {})
      raise Errors::MissingToken if token.blank?

      JWT.decode(token, key, true, custom_options.merge({ algorithm: }))
    rescue JWT::ExpiredSignature
      raise Errors::ExpiredSignature
    rescue JWT::DecodeError
      raise Errors::DecodeError
    end
  end
end
