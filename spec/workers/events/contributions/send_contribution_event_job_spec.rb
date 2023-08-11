require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::Contributions::SendContributionEventJob, type: :worker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let(:person_payment) { create(:person_payment) }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }
    let(:job) { described_class }

    let(:event) do
      OpenStruct.new({
                       name: 'contributed',
                       data: {
                         integration_id: person_payment.integration_id,
                         receiver_type: person_payment.receiver_type,
                         receiver_id: person_payment.receiver_id,
                         currency: person_payment.currency,
                         platform: person_payment.platform,
                         amount: person_payment.formatted_amount,
                         paid_date: person_payment.paid_date,
                         status: person_payment.status,
                         offer_id: person_payment.offer_id,
                         total_number_of_contributions: person_payment.payer.person_payments.count
                       }
                     })
    end

    before do
      create(:ribon_config)
      allow(job).to receive(:perform_later).with(person_payment:)
      allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
      allow(event_service_double).to receive(:call)
    end

    context 'when it calls with contribution params' do
      it 'calls the send event function with correct arguments' do
        job.perform_now(person_payment:)

        expect(EventServices::SendEvent).to have_received(:new).with(user: person_payment.payer.user, event:)
      end
    end
  end
end
