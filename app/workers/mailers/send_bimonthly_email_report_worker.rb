module Mailers
  class SendBimonthlyEmailReportWorker
    include Sidekiq::Worker
    sidekiq_options queue: :mailers

    def perform(*_args)
      users_that_donated_passed_3_months.each do |user|
        Mailers::HandleBimonthlyEmailReportJob.perform_later(user:)
      end
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end

    private

    def users_that_donated_passed_3_months
      start_date = 3.months.ago.beginning_of_day
      end_date = 2.months.ago.end_of_day

      User.joins(:user_donation_stats).where(user_donation_stats: { last_donation_at: start_date..end_date })
    end
  end
end
