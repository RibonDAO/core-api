module Jwt
  module Auth
    module Decoder
      module_function

      def decode!(access_token, verify: true)
        decoded = JWT.decode(access_token, Secret.secret, verify, verify_iat: true)[0]
        raise Errors::InvalidToken if decoded.blank?

        decoded.symbolize_keys
      end

      def decode(access_token, verify: true)
        decode!(access_token, verify:)
      rescue StandardError
        nil
      end
    end
  end
end
