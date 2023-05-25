module Jwt
  module Revoker
    module_function

    def revoke(decoded_token:, authenticatable:)
      jti = decoded_token.fetch(:jti)
      exp = decoded_token.fetch(:exp)

      Jwt::Allowlister.remove_allowlist!(jti:)
      Jwt::Blocklister.blocklist!(
        jti:,
        exp:,
        authenticatable:
      )
    rescue StandardError
      raise Errors::Jwt::InvalidToken
    end
  end
end
