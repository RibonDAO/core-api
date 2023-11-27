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
        user.update!(email: dummy_email, deleted_at:)

        user.user_profile&.destroy
        user.account&.update!(uid: dummy_email, deleted_at:)
      end
    end

    private

    def dummy_email
      "deleted_user+#{user.id}@ribon.io"
    end

    def deleted_at
      Time.zone.now
    end
  end
end
