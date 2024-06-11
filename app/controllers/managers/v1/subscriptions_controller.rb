module Managers
  module V1
    class SubscriptionsController < ManagersController

      def upload_csv_and_create_subscriptions
        emails = params[:csv_content].split("\r\n")[1..]
        offer_id = params[:offer_id]
        integration_id = params[:integration_id]
        offer = Offer.find(offer_id)

        result = create_subscriptions(emails, offer, integration_id)

        if result[:failed].empty?
          render json: { message: 'All subscriptions created successfully' }, status: :created
        else
          render json: {
            message: 'Some subscriptions failed:',
            success: result[:success],
            failed: result[:failed],
            failed_emails: result[:failed].pluck(:email)
          }, status: :unprocessable_entity
        end
      end

      private

      def subscription_params
        params.permit(:csv_content, :offer_id, :integration_id)
      end

      # rubocop:disable Metrics/MethodLength
      def create_subscriptions(emails, offer, integration_id)
        success = []
        failed = []

        emails.each do |email|
          args = {
            email:,
            offer:,
            integration_id:
          }

          command = ::Givings::Subscriptions::CreateDirectTransferSubscription.new(args).call

          if command.success?
            success << email
          else
            failed << { email:, errors: command.errors.full_messages }
          end
        end

        { success:, failed: }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
