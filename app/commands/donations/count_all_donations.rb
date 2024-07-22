module Donations
  class CountAllDonations < ApplicationCommand
    prepend SimpleCommand

    REDIS_KEY = 'today_donations_count_result'.freeze

    def call
      cached_result = RedisStore::HStore.get(key: REDIS_KEY)
      return cached_result if cached_result.present?

      today_donations = UserDonationStats.where(last_donation_at: Time.zone.now.all_day)
      today_donations_count = today_donations.count

      RedisStore::HStore.set(key: REDIS_KEY, value: today_donations_count,
                             expires_in: 1.minute)

      today_donations_count
    end
  end
end
