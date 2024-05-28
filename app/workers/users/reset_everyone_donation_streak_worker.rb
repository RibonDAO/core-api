module Users
  class ResetEveryoneDonationStreakWorker
    include Sidekiq::Worker
    sidekiq_options queue: :users

    def perform(*_args)
      users_donation_stats = UserDonationStats.all
      ResetDonationStreakJob.perform_later(users_donation_stats:)
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
