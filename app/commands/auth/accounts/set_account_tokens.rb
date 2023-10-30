# frozen_string_literal: true

module Auth
  module Accounts
    class SetAccountTokens < ApplicationCommand
      prepend SimpleCommand

      attr_reader :id_token

      def initialize(id_token:)
        @id_token = id_token
      end

      def call
        with_exception_handle do
          response = Request::ApiRequest.get(google_api_url)

          @account = Account.create_user_for_provider(response, 'google_oauth2')
          @account.save!
          access_token, refresh_token = Jwt::Auth::Issuer.call(@account)

          { access_token:, refresh_token: }
        end
      end

      private

      def google_api_url
        "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"
      end
    end
  end
end
