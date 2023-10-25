module Users
  module V1
    class LegacyImpactsController < AuthorizationController
      def index
        render json: LegacyUserImpactBlueprint.render(current_user.legacy_user_impacts)
      end

      def contributions
        render json: LegacyContributionsBlueprint.render(current_user.legacy_contributions.order(day: :desc))
      end
    end
  end
end
