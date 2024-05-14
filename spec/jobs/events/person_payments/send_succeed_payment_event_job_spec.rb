require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::PersonPayments::SendSucceedPaymentEventJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:event_service_double) { instance_double(EventServices::SendEvent) }
    let(:non_profit) { create(:non_profit, :with_impact) }
    let(:cause) { create(:cause) }
    let(:user) { create(:user, language: 'pt-BR') }
    let(:customer) { create(:customer, user:) }
    let(:offer) { create(:offer, price_cents: 100, currency: :brl) }
    let!(:person_payment) do
      create(:person_payment, payer: customer, receiver: non_profit, offer:,
                              status: :processing)
    end
    let(:normalizer_double) { instance_double(Impact::Normalizer) }
    let(:event) do
      OpenStruct.new({
                       name: 'succeed_payment',
                       data: {
                         amount: 'R$ 1,00',
                         receiver_name: person_payment.receiver.name,
                         impact: [1, 2, 3].join(' ')
                       }
                     })
    end

    before do
      create(:ribon_config)
      allow(Impact::Normalizer).to receive(:new).and_return(normalizer_double)
      allow(normalizer_double).to receive(:normalize).and_return([1, 2, 3])
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
