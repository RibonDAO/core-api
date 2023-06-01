module Patrons
  class PatronsController < ActionController::API
    before_action :set_language
    before_action :require_patron

    protected

    def require_patron
      render json: { message: I18n.t('patrons.not_found') }, status: :not_found unless current_patron
    end

    def current_patron
      @current_patron ||= BigDonor.find_by(email: request.headers['Email'])
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
