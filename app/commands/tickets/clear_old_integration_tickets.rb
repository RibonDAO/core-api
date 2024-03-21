module Tickets
  class ClearOldIntegrationTickets < ApplicationCommand
    prepend SimpleCommand

    attr_reader :time

    def initialize(time:)
      @time = time
    end

    def call
      with_exception_handle do
        UserIntegrationCollectedTicket.where('created_at < ?', time).delete_all
      end
    end
  end
end
