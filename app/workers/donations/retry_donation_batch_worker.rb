module Donations
  class RetryDonationBatchWorker
    include Sidekiq::Worker
    sidekiq_options queue: :donations

    def perform(*_args)
      RetryBatchTransactionsJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
