module Contributions
  class HandleUpdateContributionBalanceJob < ApplicationJob
    queue_as :default

    def perform(contribution_balance:, big_donor:)
      statistics = Service::Contributions::StatisticsService.new(contribution: contribution_balance.contribution)
                                                            .formatted_statistics
      percentage = statistics[:usage_percentage]
      send_email(big_donor, percentage) unless email_already_sent?(big_donor, 100)
    end

    private

    def email_already_sent?(big_donor, percentage)
      EmailLog.email_already_sent?(
        sendgrid_template_name: "patron_contributions_#{percentage}_percent_email_template_id",
        receiver: big_donor
      )
    end

    def send_email(big_donor, percentage)
      case percentage
      when 100
        Mailers::Contributions::SendPatronContributions100PercentEmailJob.perform_later(big_donor:)
      end
    end
  end
end
