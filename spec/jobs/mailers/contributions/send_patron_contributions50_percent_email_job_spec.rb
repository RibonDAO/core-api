require 'rails_helper'

RSpec.describe Mailers::Contributions::SendPatronContributions50PercentEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:big_donor) { create(:big_donor) }
    let(:statistics) { { boost_new_contributors: 10, contribution_receiver_name: 'Example Cause' } }

    before do
      allow(SendgridWebMailer).to receive(:send_email).and_return(OpenStruct.new(deliver_now: nil))
      allow(EmailLog).to receive(:log)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'calls the send email function with correct arguments' do
      job.perform_now(big_donor:, statistics:)

      expect(SendgridWebMailer).to have_received(:send_email)
        .with(receiver: big_donor[:email],
              dynamic_template_data: {
                first_name: big_donor[:name],
                total_engaged_people: statistics[:boost_new_contributors],
                cause_name: statistics[:contribution_receiver_name],
                dash_link: an_instance_of(String)
              },
              template_name: 'patron_contributions_50_percent_email_template_id',
              language: 'en')
    end
    # rubocop:enable RSpec/ExampleLength

    it 'logs the email' do
      job.perform_now(big_donor:, statistics:)

      expect(EmailLog).to have_received(:log).with(
        email_type: :patron_contribution,
        receiver: big_donor,
        sendgrid_template_name: 'patron_contributions_50_percent_email_template_id'
      )
    end
  end
end
