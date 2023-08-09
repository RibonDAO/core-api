module Mailers
  class SendMonthsInactivityEmailJob < ApplicationJob
    queue_as :mailers
    sidekiq_options retry: 3

    def perform
      inactive_users.each do |user|
        send_email(user)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end

    def send_email(user)
      SendgridWebMailer.send_email(
        receiver: user.email,
        dynamic_template_data: {},
        template_name: 'months_inactivity_template_id',
        language: user.language
      ).deliver_later
    end

    private

    def inactive_users
      start_date = 4.months.ago.beginning_of_day.to_date
      end_date = start_date + 1.day
      User.joins(:user_donation_stats)
          .where('last_donation_at >= ?', start_date)
          .where('last_donation_at < ?', end_date)
    end
  end
end
