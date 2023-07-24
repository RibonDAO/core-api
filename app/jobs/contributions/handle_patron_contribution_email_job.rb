module Contributions
  class HandlePatronContributionEmailJob < ApplicationJob
    queue_as :contributions

    def perform(contribution_balance:, big_donor:)
      statistics = Contributions::Statistics.new(contribution: contribution_balance.contribution)
                                            .formatted_email_statistics
      percentage = find_closest_email_percentage(statistics[:usage_percentage])
      send_email(big_donor, statistics, percentage) unless email_already_sent?(big_donor, percentage)
    end

    def find_closest_email_percentage(percentage)
      existing_email_percentages = [100, 95, 75, 50, 25, 10, 5]
      existing_email_percentages.select { |n| n <= percentage }.max
    end

    private

    def email_already_sent?(big_donor, percentage)
      EmailLog.email_already_sent?(
        email_template_name: "patron_contributions_#{percentage}_percent_email_template_id",
        receiver: big_donor
      )
    end

    def send_email(big_donor, statistics, percentage)
      mailer_class = "Mailers::Contributions::SendPatronContributions#{percentage}PercentEmailJob".constantize
      mailer_class.perform_later(big_donor:, statistics:)
    end
  end
end
