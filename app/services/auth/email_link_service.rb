module Auth
  class EmailLinkService
    attr_reader :authenticatable

    SCOPE_MAPPING = {
      BigDonor => %i[patrons app],
      Account => %i[deeplink auth]
    }.freeze

    def initialize(authenticatable:)
      @authenticatable = authenticatable
    end

    def find_or_create_auth_link
      scope = determine_scope
      URI.join(url(scope),
               "?authToken=#{auth_token}&id=#{authenticatable.id}").to_s
    end

    def valid_auth_token?(token)
      find_token_on_redis == token
    end

    private

    def auth_token
      find_token_on_redis || generate_new_auth_token
    end

    def find_token_on_redis
      RedisStore::HStore.get(key: "auth_token_#{authenticatable.class.name}_#{authenticatable.id}")
    end

    def generate_new_auth_token
      scope = determine_scope
      RedisStore::HStore.set(key: "auth_token_#{authenticatable.class.name}_#{authenticatable.id}",
                             value: SecureRandom.uuid, expires_in: token_expiration(scope))
    end

    def determine_scope
      SCOPE_MAPPING[authenticatable.class]
    end

    def token_expiration(scope)
      case scope
      when %i[patrons app]
        1.month
      else
        30.minutes
      end
    end

    def url(scope)
      case scope
      when %i[patrons app]
        URI.join(RibonCoreApi.config.dig(*scope)[:url], '/auth').to_s
      else
        RibonCoreApi.config.dig(*scope)[:url]
      end
    end
  end
end
