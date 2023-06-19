module JwtAuthenticatable
  extend ActiveSupport::Concern

  included do
    rescue_from Jwt::Errors::Unauthorized do |_e|
      render json: { message: 'Not authorized.' }, status: :unauthorized
    end

    rescue_from Jwt::Errors::MissingToken do |_e|
      render json: { message: 'Missing token.' }, status: :unauthorized
    end

    rescue_from Jwt::Errors::ExpiredSignature do |_e|
      render json: { message: 'Expired token.' }, status: :forbidden
    end

    rescue_from Jwt::Errors::DecodeError do |_e|
      render json: { message: 'Decode error' }, status: :unauthorized
    end
  end
end
