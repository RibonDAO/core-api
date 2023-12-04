# frozen_string_literal: true

module Auth
  module Accounts
    class AuthorizeAuthToken < ApplicationCommand
      prepend SimpleCommand
      attr_reader :auth_token, :authenticatable

      def initialize(auth_token:, authenticatable:)
        @auth_token = auth_token
        @authenticatable = authenticatable
      end

      def call
        with_exception_handle do
          unless Auth::EmailLinkService.new(authenticatable:).valid_auth_token?(auth_token)
            raise Jwt::Errors::Unauthorized
          end

          access_token, refresh_token = Jwt::Auth::Issuer.call(authenticatable)
          [access_token, refresh_token]
        end
      end
    end
  end
end
