module Jwt
  module Auth
    module Refresher
      module_function

      def refresh!(refresh_token:, decoded_token:, authenticatable:)
        raise Errors::MissingToken, token: 'missing refresh' unless refresh_token.present? || decoded_token.nil?

        existing_refresh_token = authenticatable.refresh_tokens.find_by_token(
          refresh_token
        )
        raise Errors::InvalidToken, token: 'invalid refresh' if existing_refresh_token.blank?

        jti = decoded_token.fetch(:jti)

        new_access_token, new_refresh_token = Issuer.call(authenticatable)
        existing_refresh_token.destroy!

        Blocklister.blocklist(jti:, exp: decoded_token.fetch(:exp), authenticatable:)
        Allowlister.remove_allowlist!(jti:)

        [new_access_token, new_refresh_token]
      end
    end
  end
end
