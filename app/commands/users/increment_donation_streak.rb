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

        if should_increment_streak?
          increment_streak
        elsif should_reset_streak?
          reset_streak
        end
      end
    end

    private

    def should_reset_streak?
      today = Time.zone.today
      yesterday = today - 1.day
      last_donation_at_date = @donation_stats.last_donation_at

      return true if last_donation_at_date.nil?
      return true if last_donation_at_date.to_date < yesterday

      false
    end

    def should_increment_streak?

       return true if @donation_stats.last_donation_at.to_date == Time.zone.yesterday

      false
    end

    def reset_streak
      @donation_stats.update(streak: 0)
    end

    def increment_streak
      @donation_stats.update(streak: @donation_stats.streak + 1) if should_increment_streak?
    end
  end
end
