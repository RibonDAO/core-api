module Managers
  module V1
    class SubscriptionsController < ManagersController
      def upload_csv
        command_result = create_subscriptions
        render_command_result_message(command_result)
      end

      private

      def subscription_params
        params.permit(:csv_content, :offer_id, :integration_id)
      end

      def offer
        @offer ||= Offer.find(subscription_params[:offer_id])
      end

      def create_subscriptions
        emails = subscription_params[:csv_content].split("\r\n")[1..]
        return if emails.empty?

        emails.map do |email|
          command = ::Givings::Subscriptions::CreateDirectTransferSubscription.new(
            email:,
            offer:,
            integration_id: subscription_params[:integration_id]
          ).call

          {
            email:,
            success: command.success?,
            error: command.errors.full_messages
          }
        end
      end

      def render_command_result_message(result)
        success = result.filter { |subscription| subscription[:success] }
        failed = result.filter { |subscription| !subscription[:success] }
        if !offer || !offer.plan
          render json: { message: 'Offer not found or does not have a plan' }, status: :unprocessable_entity
        elsif failed.empty?
          render json: { message: 'All subscriptions created successfully', success: }, status: :created
        else
          render json: {
            message: 'Some subscriptions failed:',
            success:,
            failed:
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
