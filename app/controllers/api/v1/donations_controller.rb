module Api
  module V1
    class DonationsController < ApplicationController
      def create
        command = Donations::Donate.call(integration:, non_profit:, user:, platform:)

        if command.success?
          render json: { donation: command.result }, status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def integration
        @integration ||= Integration.find donation_params[:integration_id]
      end

      def non_profit
        @non_profit ||= NonProfit.find donation_params[:non_profit_id]
      end

      def user
        @user ||= User.find_by(email: donation_params[:email])
      end

      def platform
        @platform ||= donation_params[:platform]
      end

      def donation_params
        params.permit(:integration_id,
                      :non_profit_id, :email, :platform)
      end
    end
  end
end
