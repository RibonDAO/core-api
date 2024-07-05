module Givings
  module Subscriptions
    class SendCancelSubscriptionEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :subscription

      def initialize(args)
        @subscription = args[:subscription]
      end

      # rubocop:disable Metrics/AbcSize
      def call
        if subscription.category == 'club'
          EventServices::SendEvent.new(user: subscription.payer.user,
                                       event: build_club_event(subscription)).call
        else
          EventServices::SendEvent.new(user: subscription.payer.user,
                                       event: build_event(subscription)).call
        end
      rescue StandardError => e
        errors.add(:message, e.message)
        Reporter.log(error: e, extra: { message: e.message })
      end
      # rubocop:enable Metrics/AbcSize

      private

      def build_event(subscription)
        OpenStruct.new({
                         name: 'cancel_subscription',
                         data: {
                           receiver_name: subscription.receiver.name,
                           subscription_id: subscription.id,
                           user: subscription.payer.user,
                           amount: subscription.formatted_amount,
                           url:,
                           status: subscription.status
                         }
                       })
      end

      def build_club_event(subscription)
        OpenStruct.new({
                         name: 'club',
                         data: {
                           type: 'cancellation_request',
                           subscription_id: subscription.id,
                           user: subscription.payer.user,
                           amount: subscription.formatted_amount,
                           url:,
                           status: subscription.status,
                           last_club_day: subscription.last_club_day&.strftime('%d/%m/%Y')
                         }
                       })
      end

      def jwt
        @jwt ||= ::Jwt::Encoder.encode({ subscription_id: subscription.id })
      end

      def url
        "#{RibonCoreApi.config[:dapp][:url]}/monthly-contribution-canceled?token=#{jwt}"
      end
    end
  end
end
