module Api
  module V1
    module Users
      class LegacyImpactsController < ApplicationController
        def index
          render json: UserLegacyImpactBlueprint.render(user.legacy_user_impacts)
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end
      end
    end
  end
end
