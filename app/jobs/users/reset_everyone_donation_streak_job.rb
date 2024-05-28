module Users
  class ResetEveryoneDonationStreakJob < ApplicationJob
    queue_as :users

    def perform
      users_donation_stats = UserDonationStats.all
      ResetDonationStreak.call(users_donation_stats:)
    end
  end
end
