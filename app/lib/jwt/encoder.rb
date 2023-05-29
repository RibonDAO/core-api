# frozen_string_literal: true

module Jwt
  class Encoder < Jwt::Base
    def self.encode(
      payload, key = HMAC_SECRET_KEY,
      algorithm = DEFAULT_ALGORITHM,
      expiration = 2.minutes.from_now.to_i
    )
      JWT.encode(payload, key, algorithm, { exp: expiration })
    end
  end
end
