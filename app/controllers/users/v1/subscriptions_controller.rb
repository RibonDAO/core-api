module Users
  module V1
    class SubscriptionsController < AuthorizationController
      def index
        ids = current_user.customers.pluck(:id)
        @subscriptions = Subscription.where(payer_id: ids, status: :active)

        render json: SubscriptionBlueprint.render(@subscriptions)
      end

      def send_cancel_subscription_email
        command = ::Givings::Subscriptions::SendCancelSubscriptionEmail.new(subscription:).call

        if command.success?
          render json: { message: 'Email sent' }, status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def subscription
        @subscription ||= Subscription.find params[:subscription_id]
      end
    end
  end
end
