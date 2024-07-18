# frozen_string_literal: true

module Auth
  module Accounts
    class SendOtpEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :email, :current_email, :id

      def initialize(email:, current_email:, id:)
        @email = email
        @current_email = current_email
        @id = id
      end

      def call
        with_exception_handle do
          raise 'Email or id must be present' unless email.present? || id.present?

          check_if_user_email_matches
          @account = create_or_find_account
          access_token, refresh_token = Jwt::Auth::Issuer.call(@account)
          Users::CreateProfile.call(data: {}, user: @account.user)
          send_event
          { access_token:, refresh_token:, user: @account.user, account_id: @account.id }
        rescue StandardError => e
          errors.add(:message, e.message)
        end
      end

      private

      def check_if_user_email_matches
        return if current_email.blank?

        new_email = email || Account.find(id)&.email

        raise 'Email does not match' if current_email != new_email
      end

      def create_or_find_account
        return Users::CreateAccount.call(data: email, provider: 'otp').result if email.present?

        Account.find(id)
      end

      def send_event
        EventServices::SendEvent.new(user: @account.user,
                                     event: build_event(@account)).call
      rescue StandardError => e
        errors.add(:message, e.message)
        Reporter.log(error: e, extra: { message: e.message })
      end

      def code(account)
        OtpCodeService.new(authenticatable: account).create_otp_code
      end

      def build_event(account)
        OpenStruct.new({
                         name: 'authorize_email_with_otp',
                         data: {
                           email: account.email,
                           code: code(account)
                         }
                       })
      end
    end
  end
end
