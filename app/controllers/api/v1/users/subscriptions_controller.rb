module Api
  module V1
    module Users
      class SubscriptionsController < ApplicationController
        include ::Subscriptions
        def index
          ids = user.customers.pluck(:id)
          @subscriptions = Subscription.where(payer_id: ids, status: :active)

          render json: SubscriptionBlueprint.render(@subscriptions)
        end

        def send_cancel_subscription_email
          command = ::Subscriptions::SendCancelSubscriptionEmail.new(subscription:).call

          if command.success?
            render json: { message: 'Email sent' }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def user
          @user ||= User.find params[:user_id]
        end

        def subscription
          @subscription ||= Subscription.find params[:subscription_id]
        end
      end
    end
  end
end
