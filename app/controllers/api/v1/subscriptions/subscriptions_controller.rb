module Api
  module V1
    module Subscriptions
      class SubscriptionsController < ApplicationController
        def unsubscribe
          subscription_id = ::Jwt::Decoder.decode(token: params[:token]).first['subscription_id']
          return head :unauthorized unless subscription_id

          command = ::Givings::Subscriptions::CancelSubscription.call(subscription_id:)
          if command.success?
            render json: SubscriptionBlueprint.render(command.result), status: :ok
          else
            render_errors(command.errors)
          end
        rescue StandardError
          head :unauthorized
        end

        def show
          subscription = Subscription.find(params[:id])

          render json: SubscriptionBlueprint.render(subscription)
        end
      end
    end
  end
end
