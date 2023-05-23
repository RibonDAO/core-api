module Managers
  class AuthorizationController < ApplicationController
    def google_authorization
      command = ::Manager::SetUserManagerTokens.call(id_token: params[:data]['id_token'])

      if command.success?
        create_headers(command.result)

        render json: { message: I18n.t('manager.login_success') }, status: :created
      else
        render_errors(command.errors)
      end
    end

    private

    def create_headers(tokens)
      set_header('access-token', tokens['access-token'])
      set_header('client', tokens['client'])
      set_header('expiry', tokens['expiry'])
      set_header('uid', tokens['uid'])
      set_header('token-type', tokens['token-type'])
      set_header('jwt-token', jwt_token)
    end

    def set_header(name, value)
      headers[name] = value.to_s
    end

    def jwt_token
      JWT.encode({ id_token:, exp: 24.hours.from_now }, RibonCoreApi.config[:jwt_secret_key])
    end
  end
end
