module Integrations
  module V1
    class ImpactsController < IntegrationsController
      def index
        formatted_impact = impact_service.formatted_impact

        render json: formatted_impact, status: :ok
      end

      private

      def start_date
        @start_date ||= params[:start_date]
      end

      def end_date
        @end_date ||= params[:end_date]
      end

      def impact_service
        @impact_service ||= IntegrationServices::Impact.new(integration: current_integration,
                                                            start_date:, end_date:)
      end
    end
  end
end
