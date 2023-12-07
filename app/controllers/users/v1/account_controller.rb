module Users
  module V1
    class AccountController < AuthorizationController
      def send_validated_email
        command = Auth::Accounts::SendValidatedEmail.call(user: current_user)

        if command.success?
          render json: { message: I18n.t('users.email_sent') }, status: :ok
        else
          render_errors(command.errors, :unprocessable_entity)
        end
      end

      def validate_extra_ticket
        email = ::Jwt::Decoder.decode(token: params[:token]).first['email']
        return head :unauthorized unless email

        user = User.find_by(email:)
        if user == current_user
          head :ok
        else
          head :unauthorized
        end
      rescue StandardError
        head :unauthorized
      end
    end
  end
end
