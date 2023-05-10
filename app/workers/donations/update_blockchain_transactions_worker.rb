module Donations
  class UpdateBlockchainTransactionsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :donations

    def perform(*_args)
      UpdateBlockchainTransactionsJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
