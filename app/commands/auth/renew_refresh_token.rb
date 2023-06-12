module Auth
  class RenewRefreshToken < ApplicationCommand
    prepend SimpleCommand

    attr_reader :access_token, :refresh_token

    def initialize(access_token:, refresh_token:)
      @access_token = access_token
      @refresh_token = refresh_token
    end

    def call
      with_exception_handle do
        decoded_token = Jwt::Decoder.decode(token: access_token, custom_options: { verify_expiration: false })
                                    .first.symbolize_keys
        authenticatable = UserManager.find_by(id: decoded_token[:authenticatable_id])
        new_access_token, new_refresh_token = Jwt::Auth::Refresher
                                              .refresh!(refresh_token:, decoded_token:, authenticatable:)

        [new_access_token, new_refresh_token]
      end
    end
  end
end
