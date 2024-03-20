module Tickets
  class ClearAllCollectedByIntegrationWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets

    def perform(*_args)
      Integration.all.each do |integration|
        ClearAllCollectedByIntegrationJob.perform_later(integration) if integration.available_everyday_at_midnight?
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
