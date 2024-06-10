module Managers
  module V1
    class SubscriptionsController < ManagersController
      require 'csv'

      def upload_csv_and_create_subscriptions
        # byebug
        emails = params[:csv_content].split("\r\n")[1..]
        offer_id = params[:offer_id]
        integration_id = params[:integration_id]
        if file
          render json: { message: 'Subscriptions created successfully' }, status: :ok
        else
          render json: { error: 'No file uploaded' }, status: :unprocessable_entity
        end
      end

      private

      def subscription_params
        params.permit(:csv_content, :offer_id, :integration_id, :test)
      end
    end
  end
end
