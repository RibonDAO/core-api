module Users
  module V1
    module Tickets
      class CollectController < AuthorizationController
        def collect_by_integration
          command = ::Tickets::CollectByIntegration.call(integration:, user:, platform:)

          if command.success?
            ::Tracking::AddUtm.call(utm_params:, trackable: command.result)
            render json: { ticket: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def collect_by_external_id
          command = ::Tickets::CollectByExternalId.call(integration:, user:, platform:,
                                                        external_ids: ticket_params[:external_ids])
          if command.success?
            ::Tracking::AddUtm.call(utm_params:, trackable: command.result)
            render json: { ticket: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def can_collect_by_integration
          command = ::Tickets::CanCollectByIntegration.call(integration:, user:)
          if command.success?
            render json: { can_collect: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def can_collect_by_external_id
          command = ::Tickets::CanCollectByExternalId.call(integration:, user:,
                                                           external_ids: ticket_params[:external_ids])

          if command.success?
            render json: { can_collect: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def integration
          @integration ||= Integration.find_by_id_or_unique_address ticket_params[:integration_id]
        end

        def user
          current_user
        end

        def platform
          @platform ||= ticket_params[:platform]
        end

        def ticket_params
          params.permit(:integration_id, :platform, external_ids: [])
        end

        def utm_params
          params.permit(:utm_source,
                        :utm_medium,
                        :utm_campaign)
        end
      end
    end
  end
end
