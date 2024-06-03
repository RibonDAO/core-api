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
        query = "metadata ->> 'user_id' = ? AND metadata ->> 'branch' = ? AND status = '1'"

        @integration = Integration.find_by(query, current_user.id.to_s, filter_params[:branch])

        if @integration
          render json: IntegrationBlueprint.render(@integration)
        else
          render json: { message: 'Integration not found' }, status: :not_found
        end
      end

      private

      def filter_params
        params.permit(:branch)
      end

      def integration_params
        params.permit(:name, :status, :id, :ticket_availability_in_minutes, :logo,
                      :webhook_url,
                      metadata: {},
                      integration_task_attributes: %i[id description link link_address],
                      :onboarding_title, :onboarding_description, :banner_title, :banner_description,
                      :no_tickets_title, :no_tickets_cta_text, :no_tickets_cta_url, :onboarding_image)
      end
    end
  end
end
