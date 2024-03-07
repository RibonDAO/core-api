module Tickets
  class GenerateClubMonthlyTicketsJob < ApplicationJob
    queue_as :tickets
    sidekiq_options retry: 3

    def perform(user, platform, quantity, integration)
      return unless user.club_member?

      GenerateClubTickets.call(user:, platform:, quantity:, category: :monthly, integration:)

      Tickets::SendMonthlyTicketsNotificationJob
        .set(wait_until: 1.month.from_now)
        .perform_later(user, platform, quantity, integration)
    end
  end
end
