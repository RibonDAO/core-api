module Managers
  class ManagersController < ActionController::API
    # TODO: implement authentication
    # commented for now, but keeping it here so we don't forget
    # include ApiKeyAuthenticatable
    # prepend_before_action :authenticate_with_api_key!

    rescue_from ActiveRecord::RecordNotFound do |_e|
      render json: { message: 'Not found.' }, status: :not_found
    end

    protected

    def current_manager
      @current_manager ||= 'temporary_value' # @current_bearer
    end

    def render_errors(errors, status = :unprocessable_entity)
      render json: ErrorBlueprint.render(OpenStruct.new(errors)), status:
    end
  end
end
