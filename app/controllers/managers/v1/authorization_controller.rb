module Managers
  module V1
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
        set_header('access-token', tokens[:access_token])
        set_header('refresh-token', tokens[:refresh_token]&.token)
      end

      def set_header(name, value)
        headers[name] = value.to_s
      end
    end
  end
end
