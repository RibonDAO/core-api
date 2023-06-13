module Api
  module V1
    module Integrations
      class ImpactsController < ApplicationController
        def index
          formatted_impact = impact_service.formatted_impact

          render json: IntegrationImpactBlueprint.render(formatted_impact), status: :ok
        end

        private

        def start_date
          return 7.days.ago unless params[:start_date]

          @start_date ||= Date.parse(params[:start_date]).beginning_of_day
        end

        def end_date
          return Time.zone.now unless params[:end_date]

          @end_date ||= Date.parse(params[:end_date]).end_of_day
        end

        def integration
          @integration ||= Integration.find_by_id_or_unique_address params[:integration_id]
        end

        def impact_service
          @impact_service ||= Service::Integrations::ImpactTrend.new(integration:, start_date:, end_date:)
        end
      end
    end
  end
end
