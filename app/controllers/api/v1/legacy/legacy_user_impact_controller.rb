module Api
  module V1
    module Legacy
      class LegacyUserImpactController < ApplicationController
        def create_legacy_impact
          ::Legacy::CreateLegacyUserImpactJob.perform_now(email: params[:email],
                                                          impacts: params[:impacts],
                                                          legacy_id: params[:legacy_id])
        end
      end
    end
  end
end
