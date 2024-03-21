module Tickets
  class ClearOldIntegrationTicketsJob < ApplicationJob
    queue_as :tickets
    sidekiq_options retry: 3

    def perform(time: 1.month.ago)
      ClearOldIntegrationTickets.call(time:)
    end
  end
end
