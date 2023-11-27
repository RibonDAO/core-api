# frozen_string_literal: true

module Auth
  module Accounts
    class SendAuthenticationEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :email, :id

      def initialize(email:, id:)
        @email = email
        @id = id
      end

      def call
        with_exception_handle do
          raise 'Email or id must be present' unless email.present? || id.present?

          @account = create_or_find_account
          access_token, refresh_token = Jwt::Auth::Issuer.call(@account)
          send_event
          { access_token:, refresh_token:, email: @account.email }
        rescue StandardError => e
          errors.add(:message, e.message)
        end
      end

      private

      def create_or_find_account
        return Users::CreateAccount.call(data: email, provider: 'magic_link').result if email.present?

        Account.find(id)
      end

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
        Auth::EmailLinkService.new(authenticatable: account).find_or_create_auth_link
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
