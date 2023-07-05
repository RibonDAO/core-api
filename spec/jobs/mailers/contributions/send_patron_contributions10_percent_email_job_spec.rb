require 'rails_helper'

RSpec.describe Mailers::Contributions::SendPatronContributions10PercentEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:big_donor) { create(:big_donor) }
    let(:statistics) { { top_NGO_impact: 100 } }

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
                total_engaged_people: 'pessoas que doaram tickets da contribuição',
                top_NGO_name: 'ong com maior valor recebido',
                top_NGO_impact: "impacto ong maior #{statistics[:top_NGO_impact]}",
                dash_link: an_instance_of(String)
              },
              template_name: 'patron_contributions_10_percent_email_template_id',
              language: 'en')
    end
    # rubocop:enable RSpec/ExampleLength

    it 'logs the email' do
      job.perform_now(big_donor:, statistics:)

      expect(EmailLog).to have_received(:log).with(
        email_type: :patron_contribution,
        receiver: big_donor,
        sendgrid_template_name: 'patron_contributions_10_percent_email_template_id'
      )
    end
  end
end
