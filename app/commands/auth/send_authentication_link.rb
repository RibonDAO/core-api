module Auth
  class SendAuthenticationLink
    prepend SimpleCommand

    attr_reader :authenticatable

    def initialize(authenticatable:)
      @authenticatable = authenticatable
    end

    def call
      SendgridWebMailer.send_email(receiver: authenticatable.email, dynamic_template_data:,
                                   template_name: 'authentication_email_template_id', language:).deliver_later
    rescue StandardError => e
      errors.add(:message, e.message)
    end

    private

    def language
      'en' # TODO: When patrons have their language, change this
    end

    def dynamic_template_data
      {
        url:,
        first_name: authenticatable.name
      }
    end

    def url
      EmailLinkService.new(authenticatable:).find_or_create_auth_link
    end
  end
end
