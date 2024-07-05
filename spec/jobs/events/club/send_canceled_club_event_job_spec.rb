require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::Club::SendCanceledClubEventJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class }

    let(:subscription) { create(:subscription) }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }

    let(:event) do
      OpenStruct.new({
                       name: 'club',
                       data: {
                         type: 'cancellation_confirmation',
                         subscription_id: subscription.id,
                         integration_id: subscription.integration_id,
                         currency: subscription.offer.currency,
                         platform: subscription.platform,
                         amount: subscription.formatted_amount,
                         status: subscription.status,
                         offer_id: subscription.offer_id,
                         last_club_day: subscription.last_club_day&.strftime('%d/%m/%Y')
                       }
                     })
    end

    before do
      create(:ribon_config)
      allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
      allow(event_service_double).to receive(:call)
    end

    it 'calls the send event function with correct arguments' do
      perform_job.perform_now(subscription:)

      expect(EventServices::SendEvent).to have_received(:new).with(
        user: subscription.payer.user, event:
      )
    end
  end
end
