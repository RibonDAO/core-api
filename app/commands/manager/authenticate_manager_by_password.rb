# frozen_string_literal: true

module Manager
  class AuthenticateManagerByPassword < ApplicationCommand
    prepend SimpleCommand
    attr_reader :email, :password

    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      with_exception_handle do
        @user_manager = UserManager.find_by(email:)
        raise Jwt::Errors::InvalidPassword unless @user_manager.valid_password?(password)

        access_token, refresh_token = Jwt::Auth::Issuer.call(@user_manager)
        { access_token:, refresh_token: }
      end
    end
  end
end
