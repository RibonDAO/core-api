require 'rails_helper'

RSpec.describe Mailers::HandleBimonthlyEmailReportJob do
  let(:user) { create(:user) }

  describe '#perform' do
    before do
      allow(SendgridWebMailer).to receive(:send_email)
    end

    it 'sends a bimonthly donation report email to the user' do
      described_class.perform_now(user:)

      expect(SendgridWebMailer).to have_received(:send_email).with(
        receiver: user.email,
        dynamic_template_data: {
          months_active: an_instance_of(Integer),
          total_donations_report: an_instance_of(Integer)
        },
        template_name: 'free_user_two_months_report_template_id',
        language: user.language
      )
    end
  end

  describe '#dynamic_template_data' do
    it 'returns the correct data for the email template' do
      expect(described_class.new.dynamic_template_data(user)).to eq(
        {
          months_active: 0,
          total_donations_report: 0
        }
      )
    end
  end
end
