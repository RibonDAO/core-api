module Users
  module V1
    class ImpactsController < AuthorizationController
      def index
        render json: UserImpactBlueprint.render(current_user.impact)
      end

      def donations_count
        render json: { donations_count: donations.count }
      end

      def app_donations_count
        render json: { app_donations_count: app_donations.count }
      end

      private

      def donations
        @donations ||= current_user.donations
      end

      def app_donations
        @app_donations ||= donations.where(platform: 'app')
      end
    end
  end
end
