module Users
  module V1
    module Tickets
      class DonationsController < ApplicationController
        def donate
          command = ::Tickets::Donate.call(integration:, non_profit:, user:, platform:, quantity:)

          if command.success?
            ::Tracking::AddUtm.call(utm_params:, trackable: command.result)
            render json: { donation: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def integration
          @integration ||= Integration.find_by_id_or_unique_address ticket_params[:integration_id]
        end

        def non_profit
          @non_profit ||= NonProfit.find ticket_params[:non_profit_id]
        end

        def user
          @user ||= User.find_by(email: ticket_params[:email])
        end

        def platform
          @platform ||= ticket_params[:platform]
        end

        def quantity
          @quantity ||= ticket_params[:quantity]
        end

        def ticket_params
          params.permit(:integration_id, :non_profit_id, :email, :platform, :quantity)
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
