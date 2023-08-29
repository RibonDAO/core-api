module Api
  module V1
    module Subscriptions
      class SubscriptionsController < ApplicationController
        include ::Subscriptions

        def unsubscribe
          subscription_id = ::Jwt::Decoder.decode(token: params[:token])
          return head :unauthorized unless subscription_id

          command = ::Subscriptions::CancelSubscription.call(subscription_id:)

          if command.success?
            head :ok
          else
            render_errors(command.errors)
          end
        end

        def show
          subscription = Subscription.find(params[:id])

          render json: SubscriptionBlueprint.render(subscription)
        end
      end
    end
  end
end