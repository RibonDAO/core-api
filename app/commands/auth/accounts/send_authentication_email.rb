# frozen_string_literal: true

module Auth
  module Accounts
    class SendAuthenticationEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :email

      def initialize(email:)
        @email = email
      end

      def call
        with_exception_handle do
          @account = Account.create_user_for_provider(email, 'magic_link')

          @account.save!
          access_token, refresh_token = Jwt::Auth::Issuer.call(@account)

          send_event

          { access_token:, refresh_token: }
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

      def first_account_for_user?
        @account.user.accounts.count == 1
      end

      def url(account)
        MagicLinkService.new(authenticatable: account).find_or_create_auth_link
      end

      def build_event(account)
        OpenStruct.new({
                         name: 'authorize_email',
                         data: {
                           email: account.email,
                           new_user: first_account_for_user?,
                           url: url(account)
                         }
                       })
      end
    end
  end
end
