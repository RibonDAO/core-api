module Jwt
  module Encoder
    module_function

    def call(authenticatable)
      jti = SecureRandom.hex
      exp = Jwt::Encoder.token_expiry
      access_token = JWT.encode(
        {
          authenticatable_id: authenticatable.id,
          authenticatable_type: authenticatable.class.name,
          jti:,
          iat: Jwt::Encoder.token_issued_at.to_i,
          exp:
        },
        Jwt::Secret.secret
      )

      [access_token, jti, exp]
    end

    def token_expiry
      (Jwt::Encoder.token_issued_at + Jwt::Expiry.expiry).to_i
    end

    def token_issued_at
      Time.zone.now
    end
  end
end
