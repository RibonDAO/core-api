module Tickets
  class GenerateClubDailyTicketsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets

    def perform(*_args)
      Subscription.active_from_club.each do |subscriptions|
        Tickets::GenerateClubDailyTicketsJob.perform_later(user: subscriptions.payer.user,
                                                           platform: subscriptions.platform,
                                                           quantity: subscriptions.offer.plan.daily_tickets,
                                                           source: :club)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
