module JwtApiKeyAuthenticatable
  extend ActiveSupport::Concern

  class UnauthorizedError < StandardError
  end

  def authenticate_with_jwt_api_key!
    authenticator(bearer_token)
  end

  private

  def decode_token(token)
    JWT.decode(token, RibonCoreApi.config[:jwt_secret_key]).first
  rescue JWT::DecodeError
    raise UnauthorizedError, 'Not authorized'
  end

  def authenticator(http_token)
    decoded_token = decode_token(http_token)
    raise UnauthorizedError, 'Not authorized - empty token' if decoded_token.nil?

    decoded_token == access_token ? decoded_token : raise(UnauthorizedError, 'Not authorized')
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header&.match(pattern)
  end

  def access_token
    request.headers['AccessToken']
  end
end
