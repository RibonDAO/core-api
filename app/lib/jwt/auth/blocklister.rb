module Jwt
  module Auth
    module Blocklister
      module_function

      def blocklist!(jti:, exp:, authenticatable:)
        authenticatable.blocklisted_tokens.create!(
          jti:,
          exp: Time.zone.at(exp)
        )
      end

      def blocklist(jti:, exp:, authenticatable:)
        blocklist!(jti:, exp:, authenticatable:)
      rescue StandardError
        nil
      end

      def blocklisted?(jti:)
        BlocklistedToken.exists?(jti:)
      end
    end
  end
end
