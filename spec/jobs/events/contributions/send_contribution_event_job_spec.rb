require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::Contributions::SendContributionEventJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }
    let(:normalizer_double) { instance_double(Impact::Normalizer) }

    before do
      create(:ribon_config)
      allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
      allow(normalizer_double).to receive(:normalize).and_return([1, 2, 3])
      allow(event_service_double).to receive(:call)
    end

    context 'when there is a subscription' do
      describe 'calls with contribution params' do
        let(:cause) { create(:cause) }
        let(:subscription) { create(:subscription, payer: customer, receiver: cause) }
        let(:person_payment) do
          create(:person_payment, payer: customer, receiver: cause, subscription:)
        end
        let(:contribution) { create(:contribution, person_payment:) }
        let(:normalizer_double) { instance_double(Impact::Normalizer) }

        let(:event) do
          OpenStruct.new({
                           name: 'subscribed',
                           data: {
                             contribution_id: contribution.id,
                             integration_id: person_payment.integration_id,
                             receiver_type: person_payment.receiver_type,
                             receiver_id: person_payment.receiver_id,
                             currency: person_payment.currency,
                             platform: person_payment.platform,
                             amount: person_payment.formatted_amount,
                             paid_date: person_payment.paid_date.strftime('%d/%m/%Y'),
                             status: person_payment.status,
                             offer_id: person_payment.offer_id,
                             total_number_of_contributions: customer.contributions.count,
                             impact: Money.from_cents(
                               (person_payment.offer.price_cents * 0.2) + person_payment.offer.price_cents, 'BRL'
                             ).format,
                             receiver_name: person_payment.receiver.name,
                             payment_day: person_payment.paid_date.strftime('%d'),
                             new_subscription: true
                           }
                         })
        end

        it 'calls the send event function from subscription with the correct arguments' do
          perform_job.perform_now(contribution:)

          expect(EventServices::SendEvent)
            .to have_received(:new)
            .with(user: contribution.person_payment.payer.user, event:)
        end
      end
    end

    context 'when is not a subscription' do
      before do
        allow(Impact::Normalizer).to receive(:new).and_return(normalizer_double)
      end

      describe 'calls with contribution params' do
        let(:non_profit) { create(:non_profit, :with_impact) }
        let(:person_payment) { create(:person_payment, payer: customer, receiver: non_profit) }
        let(:contribution) { create(:contribution, person_payment:) }

        let(:event) do
          OpenStruct.new({
                           name: 'contributed',
                           data: {
                             contribution_id: contribution.id,
                             integration_id: person_payment.integration_id,
                             receiver_type: person_payment.receiver_type,
                             receiver_id: person_payment.receiver_id,
                             currency: person_payment.currency,
                             platform: person_payment.platform,
                             amount: person_payment.formatted_amount,
                             paid_date: person_payment.paid_date,
                             status: person_payment.status,
                             offer_id: person_payment.offer_id,
                             total_number_of_contributions: customer.contributions.count,
                             impact: [1, 2, 3].join(' '),
                             receiver_name: person_payment.receiver.name
                           }
                         })
        end

        it 'calls the send event function from subscription with the correct arguments' do
          perform_job.perform_now(contribution:)

          expect(EventServices::SendEvent)
            .to have_received(:new)
            .with(user: contribution.person_payment.payer.user, event:)
        end
      end
    end
  end
end
