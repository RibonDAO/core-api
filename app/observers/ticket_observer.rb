# not being used
class TicketObserver < ActiveRecord::Observer
  def after_create(ticket)
    cached_tickets = RedisStore::HStore.get(key: "tickets-#{ticket.user_id}") || database_tickets(ticket.user)
    if ticket.status == 'collected'
      RedisStore::HStore.set(key: "tickets-#{ticket.user_id}",
                             value: cached_tickets + 1)
    end
  rescue StandardError
    nil
  end

  def after_destroy(ticket)
    cached_tickets = RedisStore::HStore.get(key: "tickets-#{ticket.user_id}") || database_tickets(ticket.user)
    RedisStore::HStore.set(key: "tickets-#{ticket.user_id}", value: cached_tickets - 1)
  rescue StandardError
    nil
  end

  def after_update(ticket)
    cached_tickets = RedisStore::HStore.get(key: "tickets-#{ticket.user_id}") || 0
    if ticket.status == 'collected'
      RedisStore::HStore.set(key: "tickets-#{ticket.user_id}",
                             value: cached_tickets + 1)
    end
  rescue StandardError
    nil
  end

  def database_tickets(user)
    Ticket.where(user:, status: :collected).count
  end
end
