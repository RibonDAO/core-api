# frozen_string_literal: true

module Auth
  module Accounts
    class AuthorizeOtpCode < ApplicationCommand
      prepend SimpleCommand
      attr_reader :otp_code, :authenticatable

      def initialize(otp_code:, authenticatable:)
        @otp_code = otp_code
        @authenticatable = authenticatable
      end

      def call
        with_exception_handle do
          unless Auth::OtpCodeService.new(authenticatable:).valid_otp_code?(otp_code)
            raise Jwt::Errors::Unauthorized
          end

          access_token, refresh_token = Jwt::Auth::Issuer.call(authenticatable)
          [access_token, refresh_token]
        end
      end
    end
  end
end
