module Users
  module V1
    module Tickets
      class TicketsController < AuthorizationController
        def to_collect
          @tickets = current_user.tickets.where(status: :to_collect, source: ticket_params[:source])
          @daily_tickets = @tickets.where(category: :daily).count

          @monthly_tickets = @tickets.where(category: :monthly).count

          render json: { daily_tickets: @daily_tickets, monthly_tickets: @monthly_tickets }, status: :ok
        end

        private

        def ticket_params
          params.permit(:source)
        end
      end
    end
  end
end
