module Tickets
  class UpdateDirectTransferSubscriptionsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :subscriptions

    def perform(*_args)
      Subscription::UpdatedDirectTransferSubscriptionsJob.perform_later
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
