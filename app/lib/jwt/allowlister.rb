module Jwt
  module Allowlister
    module_function

    def allowlist!(jti:, exp:, user:)
      user.allowlisted_tokens.create!(
        jti:,
        exp: Time.zone.at(exp)
      )
    end

    def remove_allowlist!(jti:)
      allowlist = AllowlistedToken.find_by(
        jti:
      )
      allowlist.destroy if allowlist.present?
    end

    def allowlisted?(jti:)
      AllowlistedToken.exists?(jti:)
    end
  end
end
