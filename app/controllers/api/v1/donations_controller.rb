module Api
  module V1
    class DonationsController < ApplicationController
      def create
        authorize!(:create, Donation, message: I18n.t('donations.blocked_message'))

        command = Donations::Donate.call(integration:,
                                         non_profit:,
                                         user:)

        if command.success?
          render json: { transaction_hash: command.result }, status: :ok
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

      def donation_params
        params.permit(:integration_id,
                      :non_profit_id, :email)
      end
    end
  end
end
