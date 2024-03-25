module Users
  module V1
    class IntegrationsController < AuthorizationController
      def create
        command = ::Integrations::CreateIntegration.call(integration_params)
        if command.success?
          render json: IntegrationBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @integration = Integration.find_by("metadata -> 'user_id' = ?", current_user.id.to_s)

        render json: IntegrationBlueprint.render(@integration)
      end

      private

      def integration_params
        metadata = params[:metadata].present? ? JSON.parse(params[:metadata]) : {}

        params.permit(:name, :status, :id, :ticket_availability_in_minutes, :logo, :webhook_url,
                      integration_task_attributes: %i[id description link link_address]).merge(metadata:)
      end
    end
  end
end
