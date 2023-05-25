module Jwt
  module Refresher
    module_function

    def refresh!(refresh_token:, decoded_token:, authenticatable:)
      raise Errors::Jwt::MissingToken, token: 'refresh' unless refresh_token.present? || decoded_token.nil?

      existing_refresh_token = authenticatable.refresh_tokens.find_by_token(
        refresh_token
      )
      raise Errors::Jwt::InvalidToken, token: 'refresh' if existing_refresh_token.blank?

      jti = decoded_token.fetch(:jti)

      new_access_token, new_refresh_token = Jwt::Issuer.call(authenticatable)
      existing_refresh_token.destroy!

      Jwt::Blocklister.blocklist!(jti:, exp: decoded_token.fetch(:exp), authenticatable:)
      Jwt::Allowlister.remove_allowlist!(jti:)

      [new_access_token, new_refresh_token]
    end
  end
end
