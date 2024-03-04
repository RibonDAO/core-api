module Tickets
  class GenerateClubDailyTicketsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets

    def perform(*_args)
      Subscriptions.where(status: :active).each do |subscriptions|
        Tickets::GenerateClubDailyTicketsJob.perform_later(user: subscriptions.payer, platform: subscriptions.platform, quantity: subscriptions.offer.plan.daily_tickets)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
