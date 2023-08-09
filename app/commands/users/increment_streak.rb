# frozen_string_literal: true

module Users
  class IncrementStreak < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call
      with_exception_handle do
        return unless user

        UserServices::UserTasksStreak.new(user:).increment_streak
      end
    end
  end
end
