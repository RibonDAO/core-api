module Mailers
  module Contributions
    class SendPatronContributions25PercentEmailJob < ApplicationJob
      queue_as :mailers

      def perform(big_donor:, statistics:)
        I18n.locale = language
        send_email(big_donor, statistics)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message })
      end

      private

      def send_email(big_donor, statistics)
        SendgridWebMailer.send_email(receiver: big_donor[:email],
                                     dynamic_template_data: {
                                       first_name: big_donor[:name],
                                       new_contributors: statistics[:boost_new_contributors],
                                       new_patrons: statistics[:boost_new_patrons],
                                       cause_name: statistics[:contribution_receiver].name,
                                       donation_date: statistics[:contribution_date],
                                       dash_link: dash_link(big_donor)
                                     },
                                     template_name: 'patron_contributions_25_percent_email_template_id',
                                     language:).deliver_later
        create_log(big_donor)
      end

      def dash_link(big_donor)
        Auth::EmailLinkService.new(authenticatable: big_donor).find_or_create_auth_link
      end

      def language
        'en' # TODO: When patrons have their language, change this
      end

      def create_log(big_donor)
        EmailLog.log(email_template_name: 'patron_contributions_25_percent_email_template_id',
                     email_type: :patron_contribution, receiver: big_donor)
      end
    end
  end
end
