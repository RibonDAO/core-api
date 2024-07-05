module Users
  class ResetDonationStreakJob < ApplicationJob
    queue_as :users

    def perform
      users_donation_stats = UserDonationStats.where('streak > 0 AND last_donation_at < ?', Time.zone.yesterday)
      ResetDonationStreak.call(users_donation_stats:)
    end
  end
end
