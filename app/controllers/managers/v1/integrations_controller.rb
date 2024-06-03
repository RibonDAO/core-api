module Managers
  module V1
    class IntegrationsController < ManagersController
      def index
        @integrations = Integration.order(created_at: :desc)

        render json: IntegrationBlueprint.render(@integrations, view: :manager)
      end

      def mobility_attributes
        render json: IntegrationTask.mobility_attributes
      end

      def create
        command = ::Integrations::CreateIntegration.call(integration_params)
        if command.success?
          render json: IntegrationBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @integration = Integration.find_by fetch_integration_query

        render json: IntegrationBlueprint.render(@integration, view: :manager)
      end

      def update
        command = ::Integrations::UpdateIntegration.call(integration_params)
        if command.success?
          render json: IntegrationBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def integration_params
        params.permit(:name, :status, :id, :ticket_availability_in_minutes, :logo, :webhook_url,
                      :onboarding_title, :onboarding_description, :banner_title, :banner_description,
                      :no_tickets_title, :no_tickets_cta_text, :no_tickets_cta_url, :onboarding_image,
                      integration_task_attributes: %i[id description link link_address])
      end

      def fetch_integration_query
        uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

        return { unique_address: integration_params[:id] } if uuid_regex.match?(integration_params[:id])

        { id: integration_params[:id] }
      end
    end
  end
end
