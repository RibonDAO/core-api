module Contributions
  class HandleUpdateContributionBalanceJob < ApplicationJob
    queue_as :default

    def perform(contribution_balance:, big_donor:)
      statistics = Service::Contributions::StatisticsService.new(contribution: contribution_balance.contribution)
                                                            .formatted_statistics
      percentage = statistics[:usage_percentage]
      ## TODO try to find a good way to deal with rounding to the nearest email percentage
      send_email(big_donor, statistics, percentage) unless email_already_sent?(big_donor, percentage)
    end

    private

    def email_already_sent?(big_donor, percentage)
      EmailLog.email_already_sent?(
        sendgrid_template_name: "patron_contributions_#{percentage}_percent_email_template_id",
        receiver: big_donor
      )
    end

    def send_email(big_donor, statistics, percentage)
      case percentage
      when 100
        Mailers::Contributions::SendPatronContributions100PercentEmailJob.perform_later(big_donor:)
      when 95..99
        Mailers::Contributions::SendPatronContributions95PercentEmailJob.perform_later(big_donor:, statistics:)
      end
    end
  end
end
