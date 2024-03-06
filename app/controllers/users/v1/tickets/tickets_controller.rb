module Users
  module V1
    module Tickets
      class TicketsController < AuthorizationController
        def available
          render json: { tickets: cached_tickets }, status: :ok
        end

        def to_collect
          @tickets = current_user.tickets.where(status: :to_collect)
          @daily_tickets = @tickets.where(category: :daily).count

          @monthly_tickets = @tickets.where(category: :monthly).count

          render json: { daily_tickets: @daily_tickets, monthly_tickets: @monthly_tickets }, status: :ok
        end

        private

        def cached_tickets
          RedisStore::HStore.get(key: "tickets-#{current_user.id}") || 0
        end
      end
    end
  end
end
