module Api
  module V1
    module Legacy
      class LegacyUserImpactController < ApplicationController
        def create_legacy_impact
          ::Legacy::CreateLegacyUserImpactJob.perform_later(legacy_params)
        end

        private

        def legacy_params
          params.permit(:user, :impacts)
        end
      end
    end
  end
end
