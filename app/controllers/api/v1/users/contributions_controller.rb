module Api
  module V1
    module Users
      class ContributionsController < ApplicationController
        def index
          @contributions = UserQueries.new(user:).contributions_to_causes
          render json: ContributionBlueprint.render(@contributions)
        end

        def show
          @contribution = user.contributions.find(params[:id])
          render json: ContributionBlueprint.render(@contribution, view: :with_stats)
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end
      end
    end
  end
end
