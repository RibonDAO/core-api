module Patrons
  class PatronsController < ActionController::API
    include JwtAuthenticatable

    attr_reader :current_patron, :decoded_token

    before_action :set_language
    before_action :authenticate
    before_action :require_patron

    rescue_from ActiveRecord::RecordNotFound do |_e|
      render json: { message: 'Not found.' }, status: :not_found
    end

    protected

    def authenticate
      current_patron, decoded_token = Jwt::Auth::Authenticator.call(
        headers: request.headers,
        access_token: params[:access_token]
      )

      @current_patron = current_patron
      @decoded_token = decoded_token
    end

    def require_patron
      render json: { message: I18n.t('patrons.not_found') }, status: :not_found unless @current_patron
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
