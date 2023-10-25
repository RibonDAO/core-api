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

      private

      def user_config_params
        params.permit(:allowed_email_marketing)
      end
    end
  end
end
