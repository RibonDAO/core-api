module Users
  module V1
    class IntegrationsController < AuthorizationController
      def create
        query = "metadata ->> 'user_id' = ? AND metadata ->> 'branch' = ? AND status = '1'"
        integration = Integration.find_by(query, current_user.id.to_s, filter_params[:branch] || 'referral')

        if integration
          render json: IntegrationBlueprint.render(integration), status: :ok
          return
        end

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
                      :onboarding_title, :onboarding_description, :banner_title, :banner_description,
                      :onboarding_image, metadata: {},
                                         integration_task_attributes: %i[id description link link_address])
      end
    end
  end
end
