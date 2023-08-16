module Api
  module V1
    module Payments
      class SubscriptionsController < ApplicationController
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
