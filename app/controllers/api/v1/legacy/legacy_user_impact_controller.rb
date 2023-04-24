module Api
  module V1
    module Legacy
      class LegacyUserImpactController < ApplicationController
        def create_legacy_impact
          ::Legacy::CreateLegacyUserImpactJob.perform_later(user_params, impact_params)
        end

        private

        def user_params
          params.require(:legacy_params).require(:user).permit(:email, :legacy_id, :created_at)
        end

        def impact_params
          params.require(:legacy_params).permit![:impacts] || []
        end
      end
    end
  end
end
