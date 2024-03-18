module Tickets
  class GenerateClubDailyTicketsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets

    def perform(*_args)
      Subscription.active_from_club.each do |subscription|
        Tickets::GenerateClubDailyTicketsJob.perform_later(user: subscription.payer.user,
                                                           platform: subscription.platform,
                                                           quantity: subscription.offer.plan.daily_tickets,
                                                           source: :club)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
