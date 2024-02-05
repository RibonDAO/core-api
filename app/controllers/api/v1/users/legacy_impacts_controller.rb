module Api
  module V1
    module Users
      class LegacyImpactsController < ApplicationController
        def index
          render json: LegacyUserImpactBlueprint.render(user.legacy_user_impacts)
        end

        def contributions
          render json: LegacyContributionsBlueprint.render(user.legacy_contributions.order(day: :desc))
        end

        private

        def user
          @user ||= current_user || User.find(params[:user_id])
        end
      end
    end
  end
end
