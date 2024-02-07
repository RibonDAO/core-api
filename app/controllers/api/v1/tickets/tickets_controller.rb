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
          RedisStore::HStore.get(key: "tickets-#{user.id}") || 0
        end
      end
    end
  end
end
