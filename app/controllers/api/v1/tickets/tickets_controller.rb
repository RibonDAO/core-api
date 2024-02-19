module Api
  module V1
    module Tickets
      class TicketsController < ApplicationController
        def available
          return unless user

          render json: { tickets: cached_tickets }, status: :ok
        end

        private

        def user
          @user ||= current_user
        end

        def cached_tickets
          tickets = RedisStore::HStore.get(key: "tickets-#{user.id}") || Ticket.where(user:).count
          if tickets.negative?
            RedisStore::HStore.set(key: "tickets-#{user.id}", value: 0)
            return 0
          end
          tickets
        end
      end
    end
  end
end
