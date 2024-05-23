module Api
  module V1
    module Tickets
      class DonationsController < ApplicationController
        def donate
          command = ::Tickets::Donate.call(non_profit:, user:, platform:, quantity:, integration_only: true)
          if command.success?
            donations = command.result
            donations.each do |donation|
              ::Tracking::AddUtmJob.perform_later(utm_params:, trackable: donation)
            end

            render json: { donations: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def non_profit
          @non_profit ||= NonProfit.find ticket_params[:non_profit_id]
        end

        def user
          @user ||= current_user || User.find_by(email: ticket_params[:email])
        end

        def platform
          @platform ||= ticket_params[:platform]
        end

        def quantity
          @quantity ||= ticket_params[:quantity]
        end

        def ticket_params
          params.permit(:non_profit_id, :email, :platform, :quantity)
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
