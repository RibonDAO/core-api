module Mailers
  module Contributions
    class SendPatronContributions10PercentEmailJob < ApplicationJob
      queue_as :mailers
      attr_reader :statistics

      def perform(big_donor:, statistics:)
        I18n.locale = language
        @statistics = statistics
        send_email(big_donor)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message })
      end

      private

      # rubocop:disable Metrics/AbcSize
      def send_email(big_donor)
        return unless top_donations_non_profit_impact

        SendgridWebMailer.send_email(receiver: big_donor[:email],
                                     dynamic_template_data: {
                                       first_name: big_donor[:name],
                                       total_engaged_people: statistics[:total_donors],
                                       top_NGO_name: top_donations_non_profit&.name,
                                       top_NGO_impact: top_donations_non_profit_impact,
                                       cause_name: statistics[:contribution_receiver].name,
                                       donation_date: statistics[:contribution_date],
                                       dash_link: dash_link(big_donor)
                                     },
                                     template_name: 'patron_contributions_10_percent_email_template_id',
                                     language:).deliver_later
        create_log(big_donor)
      end
      # rubocop:enable Metrics/AbcSize

      def contribution
        statistics[:contribution]
      end

      def top_donations_non_profit
        statistics[:top_donations_non_profit]
      end

      def top_donations_non_profit_impact
        impact = Service::Contributions::DirectImpactService.new(contribution:)
                                                            .direct_impact_for(top_donations_non_profit)

        return unless impact

        impact[:formatted_impact].join(' ')
      end

      def dash_link(big_donor)
        Auth::EmailLinkService.new(authenticatable: big_donor).find_or_create_auth_link
      end

      def language
        'en' # TODO: When patrons have their language, change this
      end

      def create_log(big_donor)
        EmailLog.log(email_template_name: 'patron_contributions_10_percent_email_template_id',
                     email_type: :patron_contribution, receiver: big_donor)
      end
    end
  end
end
