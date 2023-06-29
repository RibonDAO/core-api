module Mailers
  module Contributions
    class SendPatronContributions100PercentEmailJob < ApplicationJob
      queue_as :mailers

      def perform(big_donor:)
        send_email(big_donor)
      rescue StandardError => e
        Reporter.log(error: e, extra: { message: e.message })
      end

      private

      def send_email(big_donor)
        SendgridWebMailer.send_email(receiver: big_donor[:email],
                                     dynamic_template_data: {
                                       first_name: big_donor[:name],
                                       dash_link: dash_link(big_donor)
                                     },
                                     template_name: 'patron_contributions_100_percent_email_template_id',
                                     language:).deliver_now
        create_log(big_donor)
      end

      # TODO: CHANGE LINK FOR SPECIFIC CONTRIBUTION
      def dash_link(big_donor)
        Auth::EmailLinkService.new(authenticatable: big_donor).find_or_create_auth_link
      end

      def language
        'en' # TODO: When patrons have their language, change this
      end

      def create_log(big_donor)
        EmailLog.log(sendgrid_template_name: 'patron_contributions_100_percent_email_template_id',
                     email_type: :patron_contribution, receiver: big_donor)
      end
    end
  end
end
