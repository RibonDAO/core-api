class ApplicationController < ActionController::API
  before_action :set_language

  protected

  def current_user
    @current_user ||= User.find_by(email: request.headers['Email'])
  end

  def render_errors(errors, status = :unprocessable_entity)
    render json: ErrorBlueprint.render(OpenStruct.new(errors)), status:
  end

  private

  def set_language
    I18n.locale = request.headers['Language']&.to_sym || :en
  end
end
