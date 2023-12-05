module Users
  module V1
    class ProfileController < AuthorizationController
      def show
        profile = current_user.user_profile

        return if profile.nil?

        render json: UserProfileBlueprint.render(profile)
      end
    end
  end
end
