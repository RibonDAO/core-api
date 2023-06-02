require 'rails_helper'

RSpec.describe Mailers::SendUserDeletionEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:user) { create(:user) }
    let(:jwt) { 'jwt.webtoken' }

    before do
      allow(SendgridWebMailer).to receive(:send_email).and_return(OpenStruct.new({ deliver_later: nil }))
    end

    context 'when it is has a valid user and jwt' do
      it 'calls the send email function with correct arguments' do
        job.perform_now(user:, jwt:)

        expect(SendgridWebMailer).to have_received(:send_email)
          .with({ dynamic_template_data: {
                    url: "https://dapp.ribon.io/delete_account?token=#{jwt}"
                  },
                  language: user.language,
                  receiver: user.email,
                  template_name: 'user_account_deletion_id' })
      end
    end

    context 'when it is not a donation entrypoint' do
      it 'does not call the function to send the email' do
        job.perform_now(user: nil, jwt: nil)

        expect(SendgridWebMailer).not_to have_received(:send_email)
      end
    end
  end
end
