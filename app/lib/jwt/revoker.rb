module Jwt
  module Revoker
    module_function

    def revoke(decoded_token:, user:)
      jti = decoded_token.fetch(:jti)
      exp = decoded_token.fetch(:exp)

      Jwt::Allowlister.remove_allowlist!(jti:)
      Jwt::Blocklister.blocklist!(
        jti:,
        exp:,
        user:
      )
    rescue StandardError
      raise Errors::Jwt::InvalidToken
    end
  end
end
