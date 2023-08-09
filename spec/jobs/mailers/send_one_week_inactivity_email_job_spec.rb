require 'rails_helper'

RSpec.describe Mailers::SendOneWeekInactivityEmailJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    let!(:user6daysago) { create(:user) }
    let!(:user1week) { create(:user) }
    let!(:user8daysago) { create(:user) }
    let(:non_profit) { create(:non_profit, :with_impact) }
    let(:normalizer_double) { instance_double(Impact::Normalizer) }

    include_context('when mocking a request') { let(:cassette_name) { 'sendgrid_email_api' } }

    before do
      create(:ribon_config, default_ticket_value: 100)

      # user that donated 6 days ago
      create(:donation, user: user6daysago, created_at: 6.days.ago)
      create(:user_donation_stats, user: user6daysago, last_donation_at: 6.days.ago)
      # user that has donated one week ago
      create(:donation, user: user1week, created_at: 7.days.ago)
      create(:user_donation_stats, user: user1week, last_donation_at: 1.week.ago)
      # user that donated 8 days ago
      create(:donation, user: user8daysago, created_at: 8.days.ago)
      create(:user_donation_stats, user: user8daysago, last_donation_at: 8.days.ago)

      allow(SendgridWebMailer).to receive(:send_email).and_return(true)
      allow(Impact::Normalizer).to receive(:new).and_return(normalizer_double)
      allow(normalizer_double).to receive(:normalize).and_return([1, 2, 3])
      perform_job
    end

    describe 'when user donated last week' do
      it 'calls the send_email method' do
        expect(SendgridWebMailer).to have_received(:send_email).with(
          receiver: user1week.email,
          dynamic_template_data: { last_week_impact: [1, 2, 3].join(' ') },
          template_name: 'one_week_inactivity_template_id',
          language: user1week.language
        )
      end
    end

    describe 'when user donated 6 days ago' do
      it 'does not call the send_email method' do
        expect(SendgridWebMailer).not_to have_received(:send_email).with(
          receiver: user6daysago.email,
          dynamic_template_data: { last_week_impact: [1, 2, 3].join(' ') },
          template_name: 'one_week_inactivity_template_id',
          language: user6daysago.language
        )
      end
    end

    describe 'when user donated 8 days ago' do
      it 'does not call the send_email method' do
        expect(SendgridWebMailer).not_to have_received(:send_email).with(
          receiver: user8daysago.email,
          dynamic_template_data: { last_week_impact: [1, 2, 3].join(' ') },
          template_name: 'one_week_inactivity_template_id',
          language: user8daysago.language
        )
      end
    end
  end
end
