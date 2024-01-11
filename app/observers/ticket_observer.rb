class TicketObserver < ActiveRecord::Observer
  def after_create(ticket)
    cached_tickets = RedisStore::HStore.get(key: "tickets-#{ticket.user_id}") || 0
    RedisStore::HStore.set(key: "tickets-#{ticket.user.id}", value: cached_tickets + 1)
  rescue StandardError
    nil
  end

  def after_destroy(ticket)
    cached_tickets = RedisStore::HStore.get(key: "tickets-#{ticket.user_id}") || 0
    RedisStore::HStore.set(key: "tickets-#{ticket.user.id}", value: cached_tickets - 1)
  rescue StandardError
    nil
  end
end
