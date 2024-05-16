module Users
  class AddToDaysDonatingJob < ApplicationJob
    queue_as :default

    def perform(user:)
      @donation_stats = user.user_donation_stats
      return if donated_today?

      user.user_donation_stats.increment(:days_donating, 1)
    end

    def donated_today?
      today_date = Time.zone.now.to_date
      last_donation_date = @donation_stats.last_donation_at.to_date

      today_date == last_donation_date
    end
  end
end
