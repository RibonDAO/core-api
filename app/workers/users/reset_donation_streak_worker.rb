module Users
  class ResetDonationStreakWorker
    include Sidekiq::Worker
    sidekiq_options queue: :users

    def perform(*_args)
      users_donation_stats = UserDonationStats.where('streak > 0 AND last_donation_at < ?', Time.zone.yesterday)
      users_donation_stats.each do |user_donation_stats|
        ResetDonationStreakJob.perform_later(user_donation_stats:)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
