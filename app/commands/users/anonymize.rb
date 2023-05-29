# frozen_string_literal: true

module Users
  class Anonymize < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      with_exception_handle do
        user.update!(email: dummy_email)
      end
    end

    private

    def dummy_email
      "deleted_user+#{SecureRandom.hex(10)}@ribon.io"
    end
  end
end
