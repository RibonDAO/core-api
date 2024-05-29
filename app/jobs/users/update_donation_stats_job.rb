module Users
  class UpdateDonationStatsJob < ApplicationJob
    queue_as :users
    sidekiq_options retry: 3

    def perform(donation:)
      Users::IncrementDonationStreak.call(user: donation.user)
      Users::IncrementDaysDonating.call(user: donation.user)
      Users::SetUserLastDonationAt.call(user: donation.user, date_to_set: donation.created_at)
      Users::SetLastDonatedCause.call(user: donation.user, cause: donation.non_profit.cause)
    rescue StandardError
      nil
    end
  end
end
