module Api
  module V1
    module Users
      class SubscriptionsController < ApplicationController
        def index
          return [] unless current_user

          ids = current_user.customers.pluck(:id)
          @subscriptions = Subscription.where(payer_id: ids)

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

        def member?
          command = ::Users::VerifyClubMembership.new(user: current_user).call

          if command.success?
            is_member = command.result
            render json: { is_member: }, status: :ok
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
end
