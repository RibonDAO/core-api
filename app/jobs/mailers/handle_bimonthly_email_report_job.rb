module Mailers
  class HandleBimonthlyEmailReportJob < ApplicationJob
    queue_as :mailers

    def perform(user:)
      send_two_months_donation_email(user)
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end

    def send_two_months_donation_email(user)
      SendgridWebMailer.send_email(receiver: user.email,
                                   dynamic_template_data: dynamic_template_data(user),
                                   template_name: template_name(user),
                                   language: user.language).deliver_later
    end

    def dynamic_template_data(user)
      {
        months_active: UserQueries.new(user:).months_active,
        total_donations_report: UserQueries.new(user:).total_donations_report
      }
    end

    def template_name(user)
      user.promoter? ? 'promoter_two_months_report_template_id' : 'free_user_two_months_report_template_id'
    end
  end
end
