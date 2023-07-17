module Managers
  module V1
    class AuthorizationController < Managers::ManagersController
      skip_before_action :authenticate, only: %i[google_authorization refresh_token password_authorization]
      def google_authorization
        command = ::Manager::SetUserManagerTokens.call(id_token: params[:data]['id_token'])

        if command.success?
          create_headers(command.result)

          render json: { message: I18n.t('manager.login_success') }, status: :created
        else
          render_errors(command.errors)
        end
      end

      def password_authorization
        command = ::Manager::AuthenticateManagerByPassword.call(email: params[:email], password: params[:password])

        if command.success?
          create_headers(command.result)

          render json: { message: I18n.t('manager.login_success') }, status: :created
        else
          render_errors(command.errors)
        end
      end

      def refresh_token
        access_token = request.headers['Authorization']&.split('Bearer ')&.last
        command = Auth::RenewRefreshToken.call(refresh_token: params[:refresh_token], access_token:)

        if command.success?
          access_token, refresh_token = command.result
          create_headers({ access_token:, refresh_token: })

          render json: { message: I18n.t('manager.login_success') }, status: :ok
        else
          render_errors(command.errors, :unauthorized)
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
