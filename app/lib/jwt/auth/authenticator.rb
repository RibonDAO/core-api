module Jwt
  module Auth
    module Authenticator
      extend self

      def call(headers:, access_token:)
        token = access_token || Authenticator.authenticate_header(
          headers
        )
        raise Errors::MissingToken if token.blank?

        decoded_token = Decoder.decode!(token)
        authenticatable = Authenticator.authenticate_from_token(decoded_token)
        raise Errors::Unauthorized if authenticatable.blank?

        [authenticatable, decoded_token]
      end

      def authenticate_header(headers)
        headers['Authorization']&.split('Bearer ')&.last
      end

      def authenticate_from_token(decoded_token)
        id = decoded_token.fetch(:authenticatable_id)
        type = decoded_token.fetch(:authenticatable_type)

        raise Errors::InvalidToken unless valid_token?(decoded_token)

        authenticatable = find_authenticatable(id, type)
        return authenticatable if valid_authentication?(decoded_token, authenticatable)

        nil
      end

      private

      def valid_token?(decoded_token)
        decoded_token[:jti].present? &&
          decoded_token.fetch(:authenticatable_id).present? &&
          decoded_token.fetch(:authenticatable_type).present?
      end

      def find_authenticatable(id, type)
        Object.const_get(type).find(id)
      end

      def valid_authentication?(decoded_token, authenticatable)
        !blocklisted?(decoded_token[:jti]) &&
          allowlisted?(decoded_token[:jti]) &&
          valid_issued_at?(authenticatable, decoded_token)
      end

      def blocklisted?(jti)
        Blocklister.blocklisted?(jti:)
      end

      def allowlisted?(jti)
        Allowlister.allowlisted?(jti:)
      end

      def valid_issued_at?(authenticatable, decoded_token)
        !authenticatable.token_issued_at || decoded_token[:iat] >= authenticatable.token_issued_at.to_i
      end

      module Helpers
        extend ActiveSupport::Concern

        def logout!(authenticatable:, decoded_token:)
          Revoker.revoke(
            decoded_token:,
            authenticatable:
          )
        end
      end
    end
  end
end
