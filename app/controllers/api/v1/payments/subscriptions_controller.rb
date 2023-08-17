module Api
  module V1
    module Payments
      class SubscriptionsController < ApplicationController
        include ::Givings::Payment

        def unsubscribe
          command = ::Givings::Payment::CancelSubscription.call(subscription_id: params[:id])

          if command.success?
            head :ok
          else
            render_errors(command.errors)
          end
        end
        
        def subscriptions_for_customer
          user = User.find(params[:user_id])
          ids = user.customers.pluck(:id)
          @subscriptions = Subscription.where(payer_id: ids)

          render json: SubscriptionBlueprint.render(@subscriptions)
        end
      end
    end
  end
end
