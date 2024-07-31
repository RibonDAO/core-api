module Api
  module V1
    class DonationsController < ApplicationController
      def create
        command = Donations::Donate.call(integration:, non_profit:, user:, platform:)

        if command.success?
          Tracking::AddUtmJob.perform_later(utm_params:, trackable: command.result)
          render json: { donation: command.result }, status: :ok
        else
          render_errors(command.errors)
        end
      end

      def total_donations_today
        command = Donations::TotalDonationsToday.call

        if command.success?
          render json: { total_donations_today: command.result }, status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def integration
        @integration ||= Integration.find_by_id_or_unique_address donation_params[:integration_id]
      end

      def non_profit
        @non_profit ||= NonProfit.find donation_params[:non_profit_id]
      end

      def user
        @user ||= current_user || User.find_by(email: donation_params[:email])
      end

      def platform
        @platform ||= donation_params[:platform]
      end

      def donation_params
        params.permit(:integration_id,
                      :non_profit_id, :email, :platform)
      end

      def utm_params
        params.permit(:utm_source,
                      :utm_medium,
                      :utm_campaign)
      end
    end
  end
end
