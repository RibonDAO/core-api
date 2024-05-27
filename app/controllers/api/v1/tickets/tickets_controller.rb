module Api
  module V1
    module Tickets
      class TicketsController < ApplicationController
        def available
          return unless user

          render json: { tickets: database_tickets, integration_tickets: }, status: :ok
        end

        def to_collect
          return unless user

          tickets = user.tickets.where(status: :to_collect, source: tickets_params[:source])
          daily_tickets = tickets.where(category: :daily).count

          monthly_tickets = tickets.where(category: :monthly).count

          render json: { daily_tickets:, monthly_tickets: }, status: :ok
        end

        private

        def user
          @user ||= current_user
        end

        def user_tickets_collected
          @user_tickets_collected ||= user.tickets.collected
        end

        def database_tickets
          user_tickets_collected.count
        end

        def integration_tickets
          user_tickets_collected.where(source: :integration).count
        end

        def tickets_params
          params.permit(:source)
        end
      end
    end
  end
end
