# frozen_string_literal: true

module Jwt
  class Base
    DEFAULT_ALGORITHM = 'HS256'
    HMAC_SECRET_KEY   = RibonCoreApi.config[:hmac][:secret_key]
  end
end
