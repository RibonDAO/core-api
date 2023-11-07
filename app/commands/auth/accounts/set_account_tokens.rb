# frozen_string_literal: true

module Auth
  module Accounts
    class SetAccountTokens < ApplicationCommand
      prepend SimpleCommand

      attr_reader :id_token, :provider

      def initialize(id_token:, provider:)
        @id_token = id_token
        @provider = provider
      end

      def call
        with_exception_handle do
          case provider
          when 'google_oauth2'
            google_authenticate
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

      def google_api_url
        "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"
      end

      def apple_authenticate
        data = JWT.decode(id_token, nil, false).first
        create_account_and_issue_tokens(data)
      end

      def create_account_and_issue_tokens(data)
        @account = Account.create_user_for_provider(data, provider)
        @account.save!

        access_token, refresh_token = Jwt::Auth::Issuer.call(@account)

        { access_token:, refresh_token: }
      end
    end
  end
end
