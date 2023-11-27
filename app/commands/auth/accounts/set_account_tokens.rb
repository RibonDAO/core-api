# frozen_string_literal: true

module Auth
  module Accounts
    class SetAccountTokens < ApplicationCommand
      prepend SimpleCommand

      attr_reader :token, :provider

      def initialize(token:, provider:)
        @token = token
        @provider = provider
      end

      def call
        with_exception_handle do
          case provider
          when 'google_oauth2'
            google_authenticate
          when 'google_oauth2_access'
            google_access_authenticate
          when 'apple'
            apple_authenticate
          else
            raise 'Unsupported provider'
          end
        end
      end

      private

      def google_authenticate
        data = Request::ApiRequest.get(google_api_url)
        create_account_and_issue_tokens(data)
      end

      def google_access_authenticate
        data = Request::ApiRequest.get(google_access_api_url)
        create_account_and_issue_tokens(data)
      end

      def apple_authenticate
        data = JWT.decode(token, nil, false).first
        create_account_and_issue_tokens(data)
      end

      def create_account_and_issue_tokens(data)
        account = Users::CreateAccount.call(data:, provider:).result
        Users::CreateProfile.call(data:, user: account.user)

        access_token, refresh_token = Jwt::Auth::Issuer.call(account)

        [access_token, refresh_token, account.user]
      end

      def google_api_url
        "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{token}"
      end

      def google_access_api_url
        "https://www.googleapis.com/oauth2/v3/userinfo?access_token=#{token}"
      end
    end
  end
end
