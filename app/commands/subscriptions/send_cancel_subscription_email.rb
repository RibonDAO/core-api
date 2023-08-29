module Subscriptions
  class SendCancelSubscriptionEmail < ApplicationCommand
    prepend SimpleCommand

    attr_reader :subscription

    def initialize(args)
      @subscription = args[:subscription]
    end

    def call
      EventServices::SendEvent.new(user: subscription.payer.user,
                                   event: build_event(subscription)).call
    rescue StandardError => e
      errors.add(:message, e.message)
      Reporter.log(error: e, extra: { message: e.message })
    end

    private

    def build_event(subscription)
      OpenStruct.new({
                       name: 'cancel_subscription',
                       data: {
                         receiver_name: subscription.receiver.name,
                         subscription_id: subscription.id,
                         user: subscription.payer.user,
                         amount: subscription.person_payments.last.formatted_amount,
                         token: jwt,
                         status: subscription.status
                       }
                     })
    end

    def jwt
      @jwt ||= ::Jwt::Encoder.encode({ subscription_id: subscription.id })
    end
  end
end
