require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::Club::SendCanceledClubEventJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:subscription) { create(:subscription) }
    let(:offer) { create(:offer) }
    let!(:person_payment) do
      create(:person_payment, payer: customer, status: :failed, subscription:, offer:)
    end
    let(:event_service_double) { instance_double(EventServices::SendEvent) }

    let(:event) do
      OpenStruct.new({
                       name: 'club',
                       data: {
                         type: 'cancellation_confirmation',
                         subscription_id: subscription.id,
                         integration_id: person_payment.integration_id,
                         currency: person_payment.currency,
                         platform: person_payment.platform,
                         amount: person_payment.formatted_amount,
                         status: subscription.status,
                         offer_id: person_payment.offer_id,
                         last_club_day: (person_payment.created_at + 1.month).strftime('%d/%m/%Y')
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
        user: person_payment.payer.user, event:
      )
    end
  end
end
