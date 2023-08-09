require 'rails_helper'

RSpec.describe Mailers::SendMonthsInactivityEmailJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    let!(:user) { create(:user) }

    include_context('when mocking a request') { let(:cassette_name) { 'sendgrid_email_api' } }

    before do
      create(:ribon_config, default_ticket_value: 100)

      allow(SendgridWebMailer).to receive(:send_email).and_return(true)
    end

    describe 'when user donated 4 months ago week' do
      it 'calls the send_email method' do
        user.user_donation_stats.update!(last_donation_at: 4.months.ago)
        perform_job
        expect(SendgridWebMailer).to have_received(:send_email).with(
          receiver: user.email,
          dynamic_template_data: {},
          template_name: 'months_inactivity_template_id',
          language: user.language
        )
      end
    end

    describe 'when user donated 5 months ago' do
      it 'does not call the send_email method' do
        user.user_donation_stats.update!(last_donation_at: 5.months.ago)
        perform_job
        expect(SendgridWebMailer).not_to have_received(:send_email).with(
          receiver: user.email,
          dynamic_template_data: {},
          template_name: 'months_inactivity_template_id',
          language: user.language
        )
      end
    end

    describe 'when user donated 8 days ago' do
      it 'does not call the send_email method' do
        user.user_donation_stats.update!(last_donation_at: 3.months.ago)
        perform_job
        expect(SendgridWebMailer).not_to have_received(:send_email).with(
          receiver: user.email,
          dynamic_template_data: {},
          template_name: 'months_inactivity_template_id',
          language: user.language
        )
      end
    end
  end
end
