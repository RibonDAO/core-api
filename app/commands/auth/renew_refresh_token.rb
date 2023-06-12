module Auth
  class RenewRefreshToken < ApplicationCommand
    prepend SimpleCommand

    def call(access_token:, refresh_token:)
      with_exception_handle do
        decoded_token = Jwt::Decoder.decode(token: access_token, custom_options: { verify_expiration: false })
        authenticatable = UserManager.find decoded_token[:authenticatable_id]
        new_access_token, new_refresh_token = Jwt::Auth::Refresher
                                              .refresh!(refresh_token:, decoded_token:, authenticatable:)

        [new_access_token, new_refresh_token]
      end
    end
  end
end
