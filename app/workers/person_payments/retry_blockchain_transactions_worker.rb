module PersonPayments
  class RetryBlockchainTransactionsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :person_payments

    def perform(*_args)
      RetryBlockchainTransactionsJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
