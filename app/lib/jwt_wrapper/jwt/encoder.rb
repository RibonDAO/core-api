module JwtWrapper
  module Jwt
    module Encoder
      def self.encode(payload, key, algorithm)
        JWT.encode(payload, key, algorithm, {
                     exp: 30.minutes.from_now.to_i
                   })
      end
    end
  end
end
