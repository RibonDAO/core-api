module Users
  module V1
    class ContributionsController < AuthorizationController
      def index
        @contributions = user.contributions
        render json: ContributionBlueprint.render(@contributions)
      end

      def labelable
        @contributions = UserQueries.new(user:).labelable_contributions
        render json: ContributionBlueprint.render(@contributions)
      end

      def show
        @contribution = user.contributions.find(params[:id])
        render json: ContributionBlueprint.render(@contribution, view: :with_stats)
      end

      private

      def user
        current_user
      end
    end
  end
end
