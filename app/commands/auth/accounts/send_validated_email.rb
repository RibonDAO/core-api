# frozen_string_literal: true

module Auth
  module Accounts
    class SendValidatedEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :user

      def initialize(user:)
        @user = user
      end

      def call
        with_exception_handle do
          send_event
        rescue StandardError => e
          errors.add(:message, e.message)
        end
      end

      private

      def send_event
        EventServices::SendEvent.new(user:,
                                     event: build_event).call
      rescue StandardError => e
        errors.add(:message, e.message)
        Reporter.log(error: e, extra: { message: e.message })
      end

      def token
        ::Jwt::Encoder.encode({ email: user.email })
      end

      def url
        URI.join(RibonCoreApi.config[:dapp][:url],
                 "/validate-extra-ticket?token=#{token}").to_s
      end

      def build_event
        OpenStruct.new({
                         name: 'validate_account',
                         data: {
                           user:,
                           url:
                         }
                       })
      end
    end
  end
end
