module Auth
  class OtpCodeService
    attr_reader :authenticatable

    def initialize(authenticatable:)
      @authenticatable = authenticatable
    end

    def create_otp_code
      RedisStore::HStore.set(key: "auth_otp_code_#{authenticatable.class.name}_#{authenticatable.id}",
                             value: generated_code, expires_in: 5.minutes)
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

    def destroy_otp_code
      RedisStore::HStore.del(key: "auth_otp_code_#{authenticatable.class.name}_#{authenticatable.id}")
    end

    def generated_code
      SecureRandom.random_number(10**6).to_s.rjust(6, '0')
    end
  end
end
