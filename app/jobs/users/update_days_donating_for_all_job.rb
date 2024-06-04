module Users
  class UpdateDaysDonatingForAllJob < ApplicationJob
    queue_as :default

    REDIS_KEY = 'LAST_UPDATE_USER_ID_KEY'.freeze

    def perform
      user_batches do |user_batch|
        update_list = user_batch.map do |user|
          { id: user.user_donation_stats.id, days_donating: user.unique_days_donating }
        end

        update_list = update_list.index_by { |ul| ul[:id] }

        UserDonationStats.update(update_list.keys, update_list.values)

        last_user_id = user_batch.last.id
        update_checkpoint(last_user_id) if last_user_id.present?
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
    # Already calculate the days donating
    # If user id cache is present, start from it
    def user_batches(&)
      scope = User
              .joins(:donations)
              .select('users.*, COUNT(DISTINCT DATE(donations.created_at)) AS unique_days_donating')
              .group('users.id')
              .includes(:user_donation_stats)

      scope = scope.where('users.id > ?', last_user_id) if last_user_id.present?

      scope.find_in_batches(batch_size: 1000, &)
    end
  end
end
