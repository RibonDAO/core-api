module Auth
  class OtpCodeService
    attr_reader :authenticatable

    SCOPE_MAPPING = {
      BigDonor => %i[patrons app],
      Account => %i[deeplink auth]
    }.freeze

    def initialize(authenticatable:)
      @authenticatable = authenticatable
      @scope = SCOPE_MAPPING[authenticatable.class] || 'unscoped'
    end

    def find_or_create_otp_code
      current_otp_code || create_otp_code
    end

    def valid_otp_code?(code)
      return false if current_otp_code != code

      destroy_otp_code
      true
    end

    private

    def current_otp_code
      RedisStore::HStore.get(key: "auth_otp_code_#{authenticatable.class.name}_#{authenticatable.id}")
    end

    def create_otp_code
      RedisStore::HStore.set(key: "auth_otp_code_#{authenticatable.class.name}_#{authenticatable.id}",
                             value: generated_code, expires_in: token_expiration(@scope))
    end

    def destroy_otp_code
      RedisStore::HStore.del(key: "auth_otp_code_#{authenticatable.class.name}_#{authenticatable.id}")
    end

    def token_expiration(scope)
      case scope
      when %i[patrons app]
        1.month
      else
        30.minutes
      end
    end

    def generated_code
      SecureRandom.random_number(10**6).to_s.rjust(6, '0')
    end
  end
end
