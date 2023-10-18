module Api
  module V1
    module Users
      class ConfigsController < ApplicationController
        def update
          user_config = user.user_config || user.build_user_config

          if user_config.update(user_config_params)
            head :ok
          else
            render json: user_config.errors, status: :unprocessable_entity
          end
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end

        def user_config_params
          params.permit(:allowed_email_marketing)
        end
      end
    end
  end
end
