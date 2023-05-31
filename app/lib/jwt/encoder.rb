# frozen_string_literal: true

module Jwt
  class Encoder < Jwt::Base
    def self.encode(
      payload,
      expiration = 30.minutes,
      key = HMAC_SECRET_KEY,
      algorithm = DEFAULT_ALGORITHM
    )
      JWT.encode(payload, key, algorithm, { exp: expiration.from_now.to_i })
    end
  end
end
