module Jwt
  module Auth
    module Issuer
      module_function

      def call(authenticatable)
        access_token, jti, exp = Encoder.call(authenticatable)
        refresh_token = authenticatable.refresh_tokens.create!
        Allowlister.allowlist!(
          jti:,
          exp:,
          authenticatable:
        )

        [access_token, refresh_token]
      end
    end
  end
end
