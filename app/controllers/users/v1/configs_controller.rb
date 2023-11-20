module Users
  module V1
    class ConfigsController < AuthorizationController
      def update
        user_config = current_user.user_config || current_user.build_user_config

        if user_config.update(user_config_params)
          head :ok
        else
          render json: user_config.errors, status: :unprocessable_entity
        end
      end

      def send_delete_account_email
        if current_user
          jwt = ::Jwt::Encoder.encode({ email: current_user.email })
          Mailers::SendUserDeletionEmailJob.perform_now(user: current_user, jwt:)

          render json: { sent: true }, status: :ok
        else
          head :unauthorized
        end
      end

      def destroy
        email = ::Jwt::Decoder.decode(token: params[:token]).first['email']
        return head :unauthorized unless email

        user = User.find_by(email:)
        command = ::Users::Anonymize.call(user)

        if command.success?
          head :ok
        else
          head :unprocessable_entity
        end
      rescue StandardError
        head :unauthorized
      end

      private

      def user_config_params
        params.permit(:allowed_email_marketing)
      end
    end
  end
end
