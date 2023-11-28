module Users
  module V1
    class ProfileController < AuthorizationController
      def show
        @profile = user.user_profile
        render json: UserProfileBlueprint.render(@profile)
      end

      private

      def user
        current_user
      end
    end
  end
end
