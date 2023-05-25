module Jwt
  module Blocklister
    module_function

    def blocklist!(jti:, exp:, user:)
      user.blocklisted_tokens.create!(
        jti:,
        exp: Time.zone.at(exp)
      )
    end

    def blocklisted?(jti:)
      BlocklistedToken.exists?(jti:)
    end
  end
end
