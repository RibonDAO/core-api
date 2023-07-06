module Contributions
  class HandleUpdateContributionBalanceJob < ApplicationJob
    queue_as :default

    def perform(contribution_balance:, big_donor:)
      statistics = Service::Contributions::StatisticsService.new(contribution: contribution_balance.contribution)
                                                            .formatted_email_statistics
      percentage = find_closest_email_percentage(statistics[:usage_percentage])
      send_email(big_donor, statistics, percentage) unless email_already_sent?(big_donor, percentage)
    end

    def find_closest_email_percentage(percentage)
      closest_percentages = [100, 95, 75, 50, 25, 10, 5]
      closest_percentages.select { |n| n <= percentage }.max
    end

    private

    def email_already_sent?(big_donor, percentage)
      EmailLog.email_already_sent?(
        sendgrid_template_name: "patron_contributions_#{percentage}_percent_email_template_id",
        receiver: big_donor
      )
    end

    def send_email(big_donor, statistics, percentage)
      if percentage == 100
        Mailers::Contributions::SendPatronContributions100PercentEmailJob.perform_later(big_donor:)
      else
        mailer_class = "Mailers::Contributions::SendPatronContributions#{percentage}PercentEmailJob".constantize
        mailer_class.perform_later(big_donor:, statistics:)
      end
    end
  end
end
