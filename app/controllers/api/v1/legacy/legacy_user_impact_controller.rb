module Api
  module V1
    module Legacy
      class LegacyUserImpactController < ApplicationController
        def create_legacy_impact
          return head :unauthorized unless bearer_token == RibonCoreApi.config[:legacy][:api_token]

          ::Legacy::CreateLegacyUserImpactJob.perform_later(user_params, impact_params)
        end

        private

        def user_params
          params.require(:legacy_params).require(:user).permit(:email, :legacy_id, :created_at)
        end

        def impact_params
          params.require(:legacy_params).permit![:impacts] || []
        end

        def bearer_token
          pattern = /^Bearer /
          header  = request.headers['Authorization']
          header.gsub(pattern, '') if header&.match(pattern)
        end
      end
    end
  end
end
