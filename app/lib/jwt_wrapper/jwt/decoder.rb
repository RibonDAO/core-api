module JwtWrapper
  module Jwt
    module Decoder
      def self.decode(token, key, algorithm)
        JWT.decode(token, key, true, { algorithm: algorithm })

      rescue JWT::ExpiredSignature
        raise 'JWT token expired'
      end
    end
  end
end