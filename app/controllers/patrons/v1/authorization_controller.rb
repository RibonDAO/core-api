module Patrons
  module V1
    class AuthorizationController < Patrons::PatronsController
      skip_before_action :authenticate, only: %i[send_authentication_email authorize_from_auth_token refresh_token]
      skip_before_action :require_patron,
                         only: %i[send_authentication_email authorize_from_auth_token refresh_token]

      def send_authentication_email
        authenticatable = BigDonor.find_by!(email: params[:email])
        command = Auth::SendAuthenticationLink.call(authenticatable:)

        if command.success?
          render json: { message: I18n.t('patrons.email_sent') }, status: :ok
        else
          render_errors(command.errors, :unprocessable_entity)
        end
      end

      def authorize_from_auth_token
        authenticatable = BigDonor.find(params[:id])
        command = Auth::AuthorizeAuthToken.call(auth_token: params[:auth_token], authenticatable:)

        if command.success?
          create_headers(command.result)

          render json: BigDonorBlueprint.render(authenticatable), status: :ok
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
