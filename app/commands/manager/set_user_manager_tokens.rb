# frozen_string_literal: true

module Manager
  class SetUserManagerTokens < ApplicationCommand
    prepend SimpleCommand

    attr_reader :id_token

    def initialize(id_token:)
      @id_token = id_token
    end

    def call
      with_exception_handle do
        response = Request::ApiRequest.get(google_api_url)
        raise Jwt::Errors::InvalidEmailDomain unless response['email'].include?('@ribon.io')

        @user_manager = UserManager.create_user_for_google(response)
        access_token, refresh_token = Jwt::Auth::Issuer.call(@user_manager)
        @user_manager.save

        { access_token:, refresh_token: }
      end
    end

    private

    def google_api_url
      "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"
    end
  end
end
