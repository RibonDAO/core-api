module Api
  module V1
    module Legacy
      class LegacyUserImpactController < ApplicationController
        def create_legacy_impact
          ::Legacy::CreateLegacyUserImpactJob.perform_now(user: params[:user],
                                                          impacts: params[:impacts])
        end
      end
    end
  end
end
