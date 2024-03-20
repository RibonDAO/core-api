module Tickets
  class GenerateClubDailyTicketsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets

    def perform(*_args)
      subscriptions_without_daily_tickets.each do |subscription|
        Tickets::GenerateClubDailyTicketsJob.perform_later(user: subscription.payer.user,
                                                           platform: subscription.platform,
                                                           quantity: subscription.offer.plan.daily_tickets,
                                                           source: :club)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end

    def subscriptions_without_daily_tickets
      subscriptions = []
      Subscription.active_from_club.each do |subscription|
        unless subscription.payer.user.tickets.receive_daily_tickets_from_club_today.exists?
          subscriptions << subscription
        end
      end
      subscriptions
    end
  end
end
