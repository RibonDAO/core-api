module Users
  class ResetEveryoneDonationStreakWorker
    include Sidekiq::Worker
    sidekiq_options queue: :users

    def perform(*_args)
      UserDonationStats.all.each do |user_donation_stats|
        ResetDonationStreakJob.perform_later(user_donation_stats:)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
