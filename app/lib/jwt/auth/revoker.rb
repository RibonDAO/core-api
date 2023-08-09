module Jwt
  module Auth
    module Revoker
      module_function

      def revoke(decoded_token:, authenticatable:)
        jti = decoded_token.fetch(:jti)
        exp = decoded_token.fetch(:exp)

        Allowlister.remove_allowlist!(jti:)
        Blocklister.blocklist!(
          jti:,
          exp:,
          authenticatable:
        )
      rescue StandardError
        raise Errors::InvalidToken
      end
    end
  end
end
