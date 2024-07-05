module Users
  class IncrementDaysDonating < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call
      with_exception_handle do
        return if donated_today?

        @user.user_donation_stats.increment(:days_donating, 1)
      end
    end

    private

    def donated_today?
      today_date = Time.zone.now.to_date
      last_donation_date = @user.user_donation_stats.last_donation_at&.to_date

      today_date == last_donation_date
    end
  end
end
