require 'rails_helper'

RSpec.describe Mailers::Contributions::SendPatronContributions5PercentEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:big_donor) { create(:big_donor) }
    let(:statistics) { { top_NGO_impact: 50, total_donors: 100 } }

    before do
      allow(SendgridWebMailer).to receive(:send_email).and_return(OpenStruct.new(deliver_later: nil))
      allow(EmailLog).to receive(:log)
    end

    it 'calls the send email function with correct arguments' do
      job.perform_now(big_donor:, statistics:)

      expect(SendgridWebMailer).to have_received(:send_email)
        .with(receiver: big_donor[:email],
              dynamic_template_data: {
                first_name: big_donor[:name],
                total_engaged_people: statistics[:total_donors],
                dash_link: an_instance_of(String)
              },
              template_name: 'patron_contributions_5_percent_email_template_id',
              language: 'en')
    end

    it 'logs the email' do
      job.perform_now(big_donor:, statistics:)

      expect(EmailLog).to have_received(:log).with(
        email_type: :patron_contribution,
        receiver: big_donor,
        sendgrid_template_name: 'patron_contributions_5_percent_email_template_id'
      )
    end
  end
end
