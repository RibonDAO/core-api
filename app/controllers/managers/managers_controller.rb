module Managers
  class ManagersController < ActionController::API
    include JwtApiKeyAuthenticatable
    prepend_before_action :authenticate_with_jwt_api_key!

    rescue_from ActiveRecord::RecordNotFound do |_e|
      render json: { message: 'Not found.' }, status: :not_found
    end

    rescue_from JwtApiKeyAuthenticatable::UnauthorizedError do |_e|
      render json: { message: 'Not authorized.' }, status: :unauthorized
    end

    protected

    def render_errors(errors, status = :unprocessable_entity)
      render json: ErrorBlueprint.render(OpenStruct.new(errors)), status:
    end
  end
end
