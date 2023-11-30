# frozen_string_literal: true

module Auth
  module Accounts
    class SendValidatedEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :email

      def initialize(email:)
        @email = email
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
        EventServices::SendEvent.new(user: @account.user,
                                     event: build_event(@account)).call
      rescue StandardError => e
        errors.add(:message, e.message)
        Reporter.log(error: e, extra: { message: e.message })
      end

      def token
        ::Jwt::Encoder.encode({ email: })
      end

      def url
        URI.join(RibonCoreApi.config[:dapp][:url],
                 "/validate-extra-ticket?token=#{token}").to_s
      end

      def build_event(account)
        OpenStruct.new({
                         name: 'validate_email',
                         data: {
                           email: account.email,
                           url:
                         }
                       })
      end
    end
  end
end
