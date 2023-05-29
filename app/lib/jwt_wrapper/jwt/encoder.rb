module JwtWrapper
  module Jwt
    module Encoder
      def self.encode(payload, key, algorithm)
        JWT.encode(payload, key, algorithm, {
                     exp: 24.hours.from_now.to_i
                   })
      end
    end
  end
end
