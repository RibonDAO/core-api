module Users
  module V1
    module Tickets
      class DonationsController < AuthorizationController
        def donate
          command = ::Tickets::Donate.call(non_profit:, user:, platform:, quantity:)

          if command.success?
            donations = command.result
            donations.each do |donation|
              ::Tracking::AddUtm.call(utm_params:, trackable: donation)
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
          @user ||= current_user
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
