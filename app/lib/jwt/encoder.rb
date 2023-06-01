# frozen_string_literal: true

module Jwt
  class Encoder < Jwt::Base
    def self.encode(
      payload,
      expiration = 30.minutes,
      key = HMAC_SECRET_KEY,
      algorithm = DEFAULT_ALGORITHM
    )
      payload[:exp] = (Time.zone.now + expiration).to_i

      JWT.encode(payload, key, algorithm)
    end
  end
end
