require 'rails_helper'

RSpec.describe Mailers::SendDonationsEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:user) { create(:user) }

    before do
      allow(SendgridWebMailer).to receive(:send_email).and_return(OpenStruct.new({ deliver_later: nil }))
    end

    context 'when it is a donation on one of the entrypoints' do
      before do
        create_list(:donation, 7, user:)
      end

      it 'calls the send email function with correct arguments' do
        job.perform_now(donation: user.donations.last)

        expect(SendgridWebMailer).to have_received(:send_email)
          .with({ dynamic_template_data: {},
                  language: user.language,
                  receiver: user.email,
                  template_name: 'user_donated_7_tickets_template_id' })
      end
    end

    context 'when it is not a donation entrypoint' do
      before do
        create_list(:donation, 2, user:)
      end

      it 'does not call the function to send the email' do
        job.perform_now(donation: user.donations.last)

        expect(SendgridWebMailer).not_to have_received(:send_email)
      end
    end
  end
end
