require 'rails_helper'

RSpec.describe Events::Users::SendUserDeletionEmailJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:user) { create(:user) }
    let(:jwt) { 'jwt.webtoken' }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }
    let(:event) do
      OpenStruct.new({
                       name: 'delete_account',
                       data: {
                         email: user.email,
                         url: 'https://dapp.ribon.io/delete_account?token=jwt.webtoken'
                       }
                     })
    end

    before do
      allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
      allow(event_service_double).to receive(:call)
    end

    context 'when it is has a valid user and jwt' do
      it 'calls the send email function with correct arguments' do
        job.perform_now(user:, jwt:)

        expect(EventServices::SendEvent).to have_received(:new)
          .with({ user:, event: })
      end
    end

    context 'when it is not a donation entrypoint' do
      it 'does not call the function to send the email' do
        job.perform_now(user: nil, jwt: nil)

        expect(EventServices::SendEvent).not_to have_received(:new)
      end
    end
  end
end
