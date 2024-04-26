# frozen_string_literal: true

module Auth
  module Accounts
    class SendAuthenticationEmail < ApplicationCommand
      prepend SimpleCommand

      attr_reader :email, :current_email, :id, :integration_id

      def initialize(email:, current_email:, id:, integration_id:)
        @email = email
        @current_email = current_email
        @id = id
        @integration_id = integration_id
      end

      def call
        with_exception_handle do
          raise 'Email or id must be present' unless email.present? || id.present?

          check_if_user_email_matches
          @account = create_or_find_account
          access_token, refresh_token = Jwt::Auth::Issuer.call(@account)
          Users::CreateProfile.call(data: {}, user: @account.user)
          send_event
          { access_token:, refresh_token:, user: @account.user }
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
        return Users::CreateAccount.call(data: email, provider: 'magic_link').result if email.present?

        Account.find(id)
      end

      def first_access_to_integration?
        return if integration_id.blank?

        integration = Integration.find_by_id_or_unique_address(integration_id)
        @account.user.user_last_donation_to(integration).nil?
      end

      def send_event
        EventServices::SendEvent.new(user: @account.user,
                                     event: build_event(@account)).call
      rescue StandardError => e
        errors.add(:message, e.message)
        Reporter.log(error: e, extra: { message: e.message })
      end

      def url(account)
        Auth::EmailLinkService.new(authenticatable: account).find_or_create_auth_link
      end

      def build_event(account)
        OpenStruct.new({
                         name: 'authorize_email',
                         data: {
                           email: account.email,
                           url: url(account)
                         }
                       })
      end
    end
  end
end
