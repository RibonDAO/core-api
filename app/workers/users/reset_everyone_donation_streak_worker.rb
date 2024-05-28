module Users
  class ResetEveryoneDonationStreakWorker
    include Sidekiq::Worker
    sidekiq_options queue: :users

    def perform(*_args)
      ResetEveryoneDonationStreakJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
