require 'rails_helper'

RSpec.describe Mailers::Contributions::SendPatronContributions25PercentEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:big_donor) { create(:big_donor) }
    let(:statistics) do
      {
        boost_new_contributors: 50,
        boost_new_patrons: 100,
        contribution_receiver: create(:cause),
        contribution_date: '1/02'
      }
    end

    before do
      allow(SendgridWebMailer).to receive(:send_email).and_return(OpenStruct.new(deliver_later: nil))
      allow(EmailLog).to receive(:log)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'calls the send email function with correct arguments' do
      job.perform_now(big_donor:, statistics:)

      expect(SendgridWebMailer).to have_received(:send_email)
        .with(receiver: big_donor[:email],
              dynamic_template_data: {
                first_name: big_donor[:name],
                new_contributors: statistics[:boost_new_contributors],
                new_patrons: statistics[:boost_new_patrons],
                cause_name: statistics[:contribution_receiver].name,
                donation_date: statistics[:contribution_date],
                dash_link: an_instance_of(String)
              },
              template_name: 'patron_contributions_25_percent_email_template_id',
              language: 'en')
    end
    # rubocop:enable RSpec/ExampleLength

    it 'logs the email' do
      job.perform_now(big_donor:, statistics:)

      expect(EmailLog).to have_received(:log).with(
        email_type: :patron_contribution,
        receiver: big_donor,
        email_template_name: 'patron_contributions_25_percent_email_template_id'
      )
    end
  end
end
