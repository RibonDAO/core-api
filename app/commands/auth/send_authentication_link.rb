module Auth
  class SendAuthenticationLink
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
                       name: 'send_patron_authentication_link',
                       data: {
                         email: authenticatable.email,
                         url:
                       }
                     })
    end

    def url
      EmailLinkService.new(authenticatable:).find_or_create_auth_link
    end
  end
end
