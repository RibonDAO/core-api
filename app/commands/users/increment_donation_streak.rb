# frozen_string_literal: true

module Users
  class IncrementDonationStreak < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user

    def initialize(user:)
      @user = user
      @donation_stats = UserDonationStats.find_by(user_id: user.id)
    end

    def call
      byebug
      with_exception_handle do
        return unless user

        increment_streak
      end
    end

    private

    def should_increment_streak?
      return true if @donation_stats.last_donation_at.to_date == Time.zone.yesterday

      false
    end

    def increment_streak
      @donation_stats.update(streak: @donation_stats.streak + 1) if should_increment_streak?
    end
  end
end
