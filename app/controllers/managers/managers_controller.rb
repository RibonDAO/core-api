module Managers
  class ManagersController < ActionController::API
    before_action :set_language
    before_action :authenticate

    rescue_from ActiveRecord::RecordNotFound do |_e|
      render json: { message: 'Not found.' }, status: :not_found
    end

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

    protected

    def authenticate
      return if ENV['NO_AUTH_MANAGER'] == 'true' && !Rails.env.production?

      current_manager, decoded_token = Jwt::Auth::Authenticator.call(
        headers: request.headers,
        access_token: params[:access_token]
      )

      @current_manager = current_manager
      @decoded_token = decoded_token
    end

    def render_errors(errors, status = :unprocessable_entity)
      render json: ErrorBlueprint.render(OpenStruct.new(errors)), status:
    end

    private

    def set_language
      I18n.locale = request.headers['Language']&.to_sym || :en
    end
  end
end
