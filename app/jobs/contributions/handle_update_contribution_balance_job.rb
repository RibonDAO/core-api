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

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def send_email(big_donor, statistics, percentage)
      case percentage
      when 100
        Mailers::Contributions::SendPatronContributions100PercentEmailJob.perform_later(big_donor:)
      when 95
        Mailers::Contributions::SendPatronContributions95PercentEmailJob.perform_later(big_donor:, statistics:)
      when 75
        Mailers::Contributions::SendPatronContributions75PercentEmailJob.perform_later(big_donor:, statistics:)
      when 50
        Mailers::Contributions::SendPatronContributions50PercentEmailJob.perform_later(big_donor:, statistics:)
      when 25
        Mailers::Contributions::SendPatronContributions25PercentEmailJob.perform_later(big_donor:, statistics:)
      when 10
        Mailers::Contributions::SendPatronContributions10PercentEmailJob.perform_later(big_donor:, statistics:)
      when 5
        Mailers::Contributions::SendPatronContributions5PercentEmailJob.perform_later(big_donor:, statistics:)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
  end
end
