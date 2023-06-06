module Jwt
  module Errors
    class ExpiredSignature < StandardError; end
    class Unauthorized < StandardError; end
    class MissingToken < StandardError; end
    class InvalidToken < StandardError; end
  end
end
