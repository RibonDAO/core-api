# frozen_string_literal: true

module Users
  class ResetDonationStreak < ApplicationCommand
    prepend SimpleCommand

    attr_reader :users_donation_stats

    def initialize(users_donation_stats:)
      @users_donation_stats = users_donation_stats
    end

    def call
      with_exception_handle do
        return if users_donation_stats&.length&.zero?

        reset_streak
      end
    end

    private

    def reset_streak
      users_donation_stats.update(streak: 0)
    end
  end
end
