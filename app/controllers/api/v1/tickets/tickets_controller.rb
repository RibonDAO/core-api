module Api
  module V1
    module Tickets
      class TicketsController < ApplicationController
        def available
          render json: { tickets: cached_tickets }, status: :ok
        end

        private

        def user
          @user ||= current_user || User.find_by(email: ticket_params[:email])
        end

        def cached_tickets
          RedisStore::HStore.get(key: "tickets-#{user.id}") || 0
        end

        def ticket_params
          params.permit(:email)
        end
      end
    end
  end
end
