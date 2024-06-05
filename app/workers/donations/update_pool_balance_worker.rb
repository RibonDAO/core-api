module Donations
  class UpdatePoolBalanceWorker
    include Sidekiq::Worker
    sidekiq_options queue: :donations

    def perform(*_args)
      return unless RibonCoreApi.config[:api_env] == 'production'

      Donations::UpdatePoolBalanceJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
