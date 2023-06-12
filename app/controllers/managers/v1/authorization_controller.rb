module Managers
  module V1
    class AuthorizationController < Managers::ManagersController
      skip_before_action :authenticate, only: %i[google_authorization refresh_token]
      def google_authorization
        command = ::Manager::SetUserManagerTokens.call(id_token: params[:data]['id_token'])

        if command.success?
          create_headers(command.result)

          render json: { message: I18n.t('manager.login_success') }, status: :created
        else
          render_errors(command.errors)
        end
      end

      def refresh_token
        decoded_token = Jwt::Decoder.decode(token: headers['Authorization']&.split('Bearer ')&.last,
                                            custom_options: { verify_expiration: false })
        current_manager = UserManager.find decoded_token[:authenticatable_id]
        access_token, refresh_token = Jwt::Auth::Refresher
                                      .refresh!(refresh_token: params[:refresh_token],
                                                decoded_token:, authenticatable: current_manager)

        create_headers({ access_token:, refresh_token: })
        render json: { message: I18n.t('manager.login_success') }, status: :ok
      rescue StandardError => e
        render json: { message: e.message }, status: :unauthorized
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
