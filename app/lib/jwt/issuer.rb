module Jwt
  module Issuer
    module_function

    def call(user)
      access_token, jti, exp = Jwt::Encoder.call(user)
      refresh_token = user.refresh_tokens.create!
      Jwt::Allowlister.allowlist!(
        jti:,
        exp:,
        user:
      )

      [access_token, refresh_token]
    end
  end
end
