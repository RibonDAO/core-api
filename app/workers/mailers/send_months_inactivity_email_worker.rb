module Mailers
  class SendMonthsInactivityEmailWorker
    include Sidekiq::Worker
    sidekiq_options queue: :mailers, retry: 3

    def perform(*_args)
      return unless Rails.env.production?

      SendMonthsInactivityEmailJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
