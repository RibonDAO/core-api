module Users
  class ResetDonationStreakJob < ApplicationJob
    queue_as :users

    def perform(user_donation_stats:)
      ResetDonationStreak.call(user_donation_stats:)
    end
  end
end
