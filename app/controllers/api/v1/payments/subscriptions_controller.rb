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
      end
    end
  end
end
