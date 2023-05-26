module JwtWrapper
  module Jwt
    module Encoder
      def self.encode(payload, key, algorithm)
        JWT.encode(payload, key, algorithm, {
          exp: DEFAULT_EXPIRY_TIME
        })
      end
    end
  end
end