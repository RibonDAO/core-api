module Users
  class UpdateDaysDonatingForAllWorker
    include Sidekiq::Worker
    sidekiq_options queue: :users

    def perform(*_args)
      UpdateDaysDonatingForAllJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
