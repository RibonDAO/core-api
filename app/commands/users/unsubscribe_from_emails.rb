# frozen_string_literal: true

module Users
  class UnsubscribeFromEmails < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user

    def initialize(email:)
      @user = User.find_by(email:)
    end

    def call
      with_exception_handle do
        return unless user

        user.user_config.update(allowed_email_marketing: false)
      end
    end
  end
end
