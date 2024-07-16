module Auth
  class SendOtpCode
    prepend SimpleCommand

    attr_reader :authenticatable

    def initialize(authenticatable:)
      @authenticatable = authenticatable
    end

    def call
      EventServices::SendEvent.new(user: authenticatable, event: build_event).call
    rescue StandardError => e
      errors.add(:message, e.message)
    end

    private

    def build_event
      OpenStruct.new({
                       name: 'send_otp_code',
                       data: {
                         email: authenticatable.email,
                         code:
                       }
                     })
    end

    def code
      OtpCodeService.new(authenticatable:).find_or_create_otp_code
    end
  end
end
