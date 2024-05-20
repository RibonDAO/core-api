module Tickets
  class GenerateClubMonthlyTicketsJob < ApplicationJob
    queue_as :tickets
    sidekiq_options retry: 3

    def perform(user:, platform:, quantity:, source:)
      GenerateClubTickets.call(user:, platform:, quantity:, category: :monthly, source:)
    end
  end
end
