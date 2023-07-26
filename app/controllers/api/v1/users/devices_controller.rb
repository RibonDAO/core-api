module Api
  module V1
    module Users
      class DevicesController < ApplicationController
        def create
          user.devices.create!(device_id: params[:device_id], device_token: params[:device_token])
          head :ok
        rescue
          head :unprocessable_entity
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end
      end
    end
  end
end
