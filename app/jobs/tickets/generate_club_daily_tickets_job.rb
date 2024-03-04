module Tickets
  class GenerateClubDailyTicketsJob < ApplicationJob
    queue_as :tickets
    sidekiq_options retry: 3
    
    def perform(user, platform, quantity)
      GenerateClubTickets.call(user:, platform:, quantity:, category: :daily)
    end
  end
end
