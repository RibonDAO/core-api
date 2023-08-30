module Givings
  module Subscriptions
    class CancelSubscription < ApplicationCommand
      prepend SimpleCommand

      attr_reader :subscription_id

      def initialize(subscription_id:)
        @subscription_id = subscription_id
      end

      def call
        if subscription&.external_id?
          unsubscribe = Service::Givings::Payment::Orchestrator.new(payload: cancel_params).call
        end

        success_unsubscribe(subscription, unsubscribe)
      rescue StandardError => e
        failure_callback(e)
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
      end

      private

      def success_unsubscribe(subscription, unsubscribe)
        return unless unsubscribe[:status] == 'canceled'

        subscription.update!(status: :canceled, cancel_date: Time.zone.at(unsubscribe[:canceled_at]))
        send_email(subscription)
        subscription
      end

      def failure_callback(err)
        errors.add(:message, err.message)
      end

      def subscription
        Subscription.find_by(id: subscription_id)
      end

      def gateway
        subscription.offer.gateway
      end

      def send_email(subscription)
        SendCancelSubscriptionEmail.new(subscription:).call
      end

      def cancel_params
        OpenStruct.new(external_identifier: subscription.external_id, operation: 'unsubscribe',
                       gateway:)
      end
    end
  end
end
