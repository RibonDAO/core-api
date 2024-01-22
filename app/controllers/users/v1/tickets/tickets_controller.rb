module Users
  module V1
    module Tickets
      class TicketsController < AuthorizationController
        def available
          render json: { tickets: cached_tickets }, status: :ok
        end

        private

        def cached_tickets
          RedisStore::HStore.get(key: "tickets-#{current_user.id}") || 0
        end
      end
    end
  end
end
