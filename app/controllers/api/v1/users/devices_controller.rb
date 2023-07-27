module Api
  module V1
    module Users
      class DevicesController < ApplicationController
        def create
          user.devices.create!(device_params)
          head :ok
        rescue StandardError
          head :unprocessable_entity
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end

        def device_params
          params.permit(:device_id, :device_token)
        end
      end
    end
  end
end
