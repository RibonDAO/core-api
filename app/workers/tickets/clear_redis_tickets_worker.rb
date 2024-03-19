module Tickets
  class ClearRedisTicketsWorker
    include Sidekiq::Worker
    sidekiq_options queue: :tickets, retry: 3

    def perform(*_args)
      User.all.each do |user|
        RedisStore::HStore.del(key: "tickets-#{user.id}")
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
