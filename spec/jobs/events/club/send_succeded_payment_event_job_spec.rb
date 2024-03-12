require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::Club::SendSuccededPaymentEventJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:subscription) { create(:subscription) }
    let(:person_payment) { create(:person_payment, payer: customer, status: :failed, subscription:) }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }

    let(:event) do
      OpenStruct.new({
                       name: 'succeded_payment_club',
                       data: {
                         subscription_id: person_payment.subscription.id,
                         integration_id: person_payment.integration_id,
                         currency: person_payment.currency,
                         platform: person_payment.platform,
                         amount: person_payment.formatted_amount,
                         status: person_payment.status,
                         offer_id: person_payment.offer_id
                       }
                     })
    end

    before do
      create(:ribon_config)
      allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
      allow(event_service_double).to receive(:call)
    end

    it 'calls the send event function with correct arguments' do
      perform_job.perform_now(person_payment:)

      expect(EventServices::SendEvent).to have_received(:new).with(
        user: person_payment.payer.user, event:
      )
    end
  end
end
