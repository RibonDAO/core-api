module Tickets
  class ClearOldIntegrationTicketsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets

    def perform(*_args)
      ClearOldIntegrationTicketsJob.perform_later

    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
