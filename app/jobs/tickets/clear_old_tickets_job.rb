module Tickets
  class ClearOldTicketsJob < ApplicationJob
    queue_as :tickets
    sidekiq_options retry: 3

    def perform(time: 1.month.ago)
      ClearOldTickets.call(time:)
    end
  end
end
