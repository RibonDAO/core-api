module Tickets
  class GenerateClubMonthlyTicketsJob < ApplicationJob
    queue_as :tickets
    sidekiq_options retry: 3

    def perform(user:, platform:, quantity:, integration:)
      return unless Users::VerifyClubMembership.call(user:).result

      GenerateClubTickets.call(user:, platform:, quantity:, category: :monthly, integration:)
    end
  end
end
