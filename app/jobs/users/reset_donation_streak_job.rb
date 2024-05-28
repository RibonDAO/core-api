module Users
  class ResetDonationStreakJob < ApplicationJob
    queue_as :users

    def perform(users_donation_stats:)
      ResetDonationStreak.call(users_donation_stats:)
    end
  end
end
