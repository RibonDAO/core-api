# frozen_string_literal: true

module Users
  class ResetDonationStreak < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user_donation_stats

    def initialize(user_donation_stats:)
      @user_donation_stats = user_donation_stats
    end

    def call
      with_exception_handle do
        return unless user_donation_stats

        reset_streak
      end
    end

    private

    def reset_streak
      @user_donation_stats.update(streak: 0)
    end
  end
end
