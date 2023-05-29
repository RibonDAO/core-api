module Mailers
  class SendUserDeletionEmailJob < ApplicationJob
    queue_as :default

    def perform(user:, jwt:)
      send_email(user, jwt) if user.present? && jwt.present?
    end

    private

    def send_email(user, jwt)
      SendgridWebMailer.send_email(receiver: user.email,
                                   dynamic_template_data: { url: url(jwt) },
                                   template_name: 'user_account_deletion_id',
                                   language: user.language).deliver_later
    end

    def url(jwt)
      "https://dapp.ribon.io/delete_account?token=#{jwt}"
    end
  end
end
