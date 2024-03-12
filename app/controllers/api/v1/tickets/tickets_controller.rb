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
          tickets = RedisStore::HStore.get(key: "tickets-#{user.id}") || database_tickets
          if tickets.negative?
            RedisStore::HStore.set(key: "tickets-#{user.id}", value: database_tickets)
            return database_tickets
          end
          tickets
        end

        def database_tickets
          Ticket.where(user:, status: :collected).count
        end
      end
    end
  end
end
