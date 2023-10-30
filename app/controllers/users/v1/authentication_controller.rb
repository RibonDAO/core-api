module Users
  module V1
    class AuthenticationController < Users::AuthorizationController
      skip_before_action :authenticate,
                         only: %i[send_authentication_email authorize_from_auth_token refresh_token
                                  google_authorization]
      skip_before_action :require_user,
                         only: %i[send_authentication_email authorize_from_auth_token refresh_token
                                  google_authorization]

      def google_authorization
        command = Auth::Accounts::SetAccountTokens.call(id_token: params[:data]['id_token'])

        if command.success?
          create_headers(command.result)

          render json: { message: I18n.t('users.login_success') }, status: :created
        else
          render_errors(command.errors)
        end
      end

      def send_authentication_email
        command = Auth::Accounts::SendAuthenticationEmail.call(email: params[:email])

        if command.success?

          render json: { message: I18n.t('users.email_sent') }, status: :ok
        else

          render_errors(command.errors, :unprocessable_entity)
        end
      end

      def authorize_from_auth_token
        authenticatable = Account.find(params[:id])
        command = Auth::Accounts::AuthorizeAuthToken.call(auth_token: params[:auth_token], authenticatable:)

        if command.success?
          access_token, refresh_token = command.result
          create_headers({ access_token:, refresh_token: })

          render json: { message: I18n.t('users.login_success') }, status: :ok
        else
          render_errors(command.errors, :unauthorized)
        end
      end

      def refresh_token
        access_token = request.headers['Authorization']&.split('Bearer ')&.last
        command = Auth::RenewRefreshToken.call(refresh_token: params[:refresh_token], access_token:)

        if command.success?
          access_token, refresh_token = command.result
          create_headers({ access_token:, refresh_token: })

          render json: { message: I18n.t('users.login_success') }, status: :ok
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
