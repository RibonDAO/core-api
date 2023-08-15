module Givings
  module Payment
    class CancelSubscription < ApplicationCommand
      prepend SimpleCommand

      attr_reader :subscription_id

      def initialize(args)
        @subscription = args[:subscription_id]
      end

      def call
        if subscription&.external_id?
          unsubscribe = Service::Givings::Payment::Orchestrator.new(payload: cancel_params).call
        end

        success_unsubscribe(subscription, unsubscribe)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message }, level: :fatal)
      end

      private

      def success_unsubscribe(subscription, unsubscribe)
        return unless unsubscribe[:status] == 'canceled'

        subscription.update(status: :canceled, cancel_date: Time.zone.at(unsubscribe[:canceled_at]))
      end

      def subscription
        Subscription.find_by(id: subscription_id)
      end

      def cancel_params
        OpenStruct.new(external_identifier: subscription.external_id, operation: 'unsubscribe',
                       gateway: 'stripe')
      end
    end
  end
end
