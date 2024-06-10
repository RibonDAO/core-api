module Managers
  module V1
    class SubscriptionsController < ManagersController

      def upload_csv_and_create_subscriptions
        emails = params[:csv_content].split("\r\n")[1..]
        offer_id = params[:offer_id]
        integration_id = params[:integration_id]
        offer = Offer.find(offer_id)

        result = create_subscriptions(emails, offer, integration_id)

        if result.success?
          render json: { message: 'Subscriptions created successfully' }, status: :created
        else
          render json: { message: 'Error creating subscriptions' }, status: :unprocessable_entity
        end
      end

      private

      def subscription_params
        params.permit(:csv_content, :offer_id, :integration_id, :test)
      end

      def create_subscriptions(emails, offer, integration_id)
        emails.each do |email|
          args = {
            email:,
            offer:,
            integration_id:
          }

          ::Givings::Subscriptions::CreateDirectTransferSubscription.new(args).call
        end
      end
    end
  end
end
