module Jwt
  module Errors
    class ExpiredSignature < StandardError; end
    class DecodeError < StandardError; end
    class Unauthorized < StandardError; end
    class MissingToken < StandardError; end
    class InvalidToken < StandardError; end
    class InvalidEmailDomain < StandardError; end
    class InvalidPassword < StandardError; end
  end
end
