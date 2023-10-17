module Api
  module V1
    module Users
      class ImpactsController < ApplicationController
        def index
          render json: UserImpactBlueprint.render(user.impact)
        end

        def donations_count
          render json: { donations_count: donations.count }
        end

        def app_donations_count
          render json: { app_donations_count: app_donations.count }
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end

        def donations
          @donations ||= user.donations
        end

        def app_donations
          @app_donations ||= donations.where(platform: 'app')
        end
      end
    end
  end
end
