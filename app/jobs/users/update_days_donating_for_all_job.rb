module Users
  class UpdateDaysDonatingForAllJob < ApplicationJob
    queue_as :default

    REDIS_KEY = 'last_updated_user_id'.freeze

    def perform
      user_batches do |user_batch|
        user_donation_stats = user_batch.map(&:user_donation_stats)

        update_list = update_list(user_donation_stats)

        UserDonationStats.update(update_list.keys, update_list.values)

        last_user = update_list.keys.last
        update_checkpoint(last_user) if last_user.present?
      end
    end

    private

    def update_checkpoint(last_user_id)
      RedisStore::HStore.set(key: REDIS_KEY, value: last_user_id)
    end

    def last_user_id
      RedisStore::HStore.get(key: REDIS_KEY)
    end

    # Finds users in batches of 1000.
    # Finds only users with donations.
    # Avoids n + 1 queries by including user_donation_stats.
    # If user id cache is present, start from it
    def user_batches(&)
      if last_user_id.present?
        User
          .where('users.id > ?', last_user_id)
          .joins(:donations)
          .group('users.id')
          .includes(:user_donation_stats)
          .find_in_batches(batch_size: 1000, &)
      else
        User
          .joins(:donations)
          .group('users.id')
          .includes(:user_donation_stats)
          .find_in_batches(batch_size: 1000, &)
      end
    end

    def update_list(donation_stats)
      donation_stats
        .map { |uds| count_uniq_days_donating(uds) }
        .index_by { |uds| uds[:id] }
    end

    def count_uniq_days_donating(user_donation_stats)
      user_id = user_donation_stats.user_id

      unique_days_count = Donation.where(user_id:).select('DISTINCT DATE(created_at)').count

      { id: user_donation_stats.id, days_donating: unique_days_count }
    end
  end
end
