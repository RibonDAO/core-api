module Api
  module V1
    module Tickets
      class TicketsController < ApplicationController
        def collect_from_integration
          command = ::Tickets::CollectFromIntegration.call(integration:, user:, platform:)

          if command.success?
            ::Tracking::AddUtm.call(utm_params:, trackable: command.result)
            render json: { ticket: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def can_collect_from_integration
          command = ::Tickets::CanCollectFromIntegration.call(integration:, user:)

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
          @user ||= User.find_by(email: ticket_params[:email])
        end

        def platform
          @platform ||= ticket_params[:platform]
        end

        def ticket_params
          params.permit(:integration_id, :email, :platform)
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
