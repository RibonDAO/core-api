class SendgridWebMailer < ApplicationMailer
  DEFAULT_CATEGORY = RibonCoreApi.config[:mailer][:default_category]

  attr_accessor :mailer

  def initialize
    @mailer = RibonMailer.new
  end

  def send_email(receiver:, dynamic_template_data:, template_name:, language:, category: DEFAULT_CATEGORY)
    data = get_mail_object(receiver, dynamic_template_data, template_name, category, language)

    mailer.send(data)
  end

  private

  def get_mail_object(receiver, dynamic_template_data, template_name, category, language)
    data = {
      personalizations: [
        {
          to: [
            {
              email: receiver
            }
          ],
          dynamic_template_data:
        }
      ],
      categories: [category],
      from: {
        email: RibonCoreApi.config[:mailer][:email_sender],
        name: RibonCoreApi.config[:mailer][:name_sender]
      },
      template_id: set_template_id(language, template_name)
    }

    data.to_json
  end

  def set_template_id(language, template_name)
    if language == 'en'
      template_name = "#{template_name}_en".to_sym
    else
      template_name.to_sym
    end
    RibonCoreApi.config[:mailer][template_name]
  end
end
