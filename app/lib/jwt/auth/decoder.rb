module Jwt
  module Auth
    module Decoder
      module_function

      def decode!(access_token)
        decoded = Jwt::Decoder.decode(token: access_token).first
        raise Errors::InvalidToken if decoded.blank?

        decoded.symbolize_keys
      end

      def decode(access_token)
        decode!(access_token)
      rescue StandardError
        nil
      end
    end
  end
end
