module Donations
  class TotalDonationsToday < ApplicationCommand
    prepend SimpleCommand

    REDIS_KEY = 'total_donations_today_result'.freeze

    def call
      with_exception_handle do
        cached_result = RedisStore::HStore.get(key: REDIS_KEY)
        return cached_result if cached_result.present?

        donations_made_today = UserDonationStats.where(last_donation_at: Time.zone.now.all_day)
        total_donations_today = donations_made_today.count

        RedisStore::HStore.set(key: REDIS_KEY, value: total_donations_today,
                               expires_in: 1.hour)

        total_donations_today
      end
    end
  end
end
