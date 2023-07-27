module Admins
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      byebug
      admin = Admin.from_omniauth(auth)
      byebug
      if admin.persisted?

        flash[:success] = t('devise.omniauth_callbacks.success', kind: 'Google')
        sign_in_and_redirect admin, event: :authentication if is_navigational_format?
      else
        flash[:error] = t('devise.omniauth_callbacks.failure', kind: 'Google', reason: 'not authorized')
        redirect_to new_admin_session_path
      end
    end

    def failure
      byebug
      flash[:error] = t('devise.omniauth_callbacks.failure', kind: 'Google', reason: 'not authorized')
      redirect_to new_admin_session_path
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      byebug
      new_admin_session_path
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || root_path
    end

    private

    def auth
      byebug
      @auth ||= request.env['omniauth.auth']
    end
  end
end
