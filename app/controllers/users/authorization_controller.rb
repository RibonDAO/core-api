module Users
  class AuthorizationController < ActionController::API
    include JwtAuthenticatable
    attr_reader :current_user, :decoded_token

    before_action :set_language
    before_action :authenticate
    before_action :require_user

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
      current_user, decoded_token = Jwt::Auth::Authenticator.call(
        headers: request.headers,
        access_token: params[:access_token]
      )

      @current_user = current_user
      @decoded_token = decoded_token
    end

    def require_user
      render json: { message: I18n.t('users.not_found') }, status: :not_found unless @current_user
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
