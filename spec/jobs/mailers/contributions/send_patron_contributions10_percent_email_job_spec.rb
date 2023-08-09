require 'rails_helper'

RSpec.describe Mailers::Contributions::SendPatronContributions10PercentEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:big_donor) { create(:big_donor) }
    let(:cause) { create(:cause, name_pt_br: 'Causa') }
    let(:statistics) do
      {
        top_donations_non_profit_name: 'ongname',
        top_donations_non_profit_impact: 50,
        total_donors: 100,
        contribution_receiver: cause,
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
                total_engaged_people: statistics[:total_donors],
                top_NGO_name: statistics[:top_donations_non_profit_name],
                top_NGO_impact: statistics[:top_donations_non_profit_impact],
                cause_name: statistics[:contribution_receiver].name,
                donation_date: statistics[:contribution_date],
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
        email_template_name: 'patron_contributions_10_percent_email_template_id'
      )
    end

    it 'set the locale language' do
      job.perform_now(big_donor:, statistics:)

      expect(I18n.locale).to eq(:en)
    end

    it 'uses the receiver name according with the language' do
      job.perform_now(big_donor:, statistics:)

      expect(cause.name).to eq(cause.name_en)
    end
  end
end
