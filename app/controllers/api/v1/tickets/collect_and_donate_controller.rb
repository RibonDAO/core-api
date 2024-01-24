module Api
  module V1
    module Tickets
      class CollectAndDonateController < ApplicationController
        def collect_and_donate_by_integration
          command = ::Tickets::CollectAndDonateByIntegration.call(integration:, user:, platform:, non_profit:)
          if command.success?
            ::Tracking::AddUtm.call(utm_params:, trackable: command.result)
            render json: { donation: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def collect_and_donate_by_external_id
          command = ::Tickets::CollectAndDonateByExternalId.call(integration:, non_profit:, user:, platform:,
                                                                 external_ids:)
          if command.success?
            ::Tracking::AddUtm.call(utm_params:, trackable: command.result)
            render json: { donations: command.result }, status: :ok
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
          params.permit(:integration_id, :email, :platform, :non_profit_id)
        end

        def non_profit
          @non_profit ||= NonProfit.find ticket_params[:non_profit_id]
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
