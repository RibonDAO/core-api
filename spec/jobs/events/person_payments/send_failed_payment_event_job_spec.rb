require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::PersonPayments::SendFailedPaymentEventJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:person_payment) { create(:person_payment, payer: customer, status: :failed) }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }

    let(:event) do
      OpenStruct.new({
                       name: 'failed_payment',
                       data: {
                         integration_id: person_payment.integration_id,
                         receiver_type: person_payment.receiver_type,
                         receiver_id: person_payment.receiver_id,
                         currency: person_payment.currency,
                         platform: person_payment.platform,
                         amount: person_payment.formatted_amount,
                         status: person_payment.status,
                         offer_id: person_payment.offer_id,
                         receiver_name: person_payment.receiver.name
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
