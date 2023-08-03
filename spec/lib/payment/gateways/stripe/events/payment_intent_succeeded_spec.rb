require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Events::PaymentIntentSucceeded do
  describe '.handle' do
    subject(:handle) { described_class.handle(event) }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let!(:payment) { create(:person_payment, external_id: 'external_id', status:, receiver: cause) }
    let(:cause) { create(:cause) }
    let(:event) do
      RecursiveOpenStruct.new({ data: { object: { id: 'external_id' } } })
    end

    before do
      allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
      allow(PersonPayments::CreateContributionJob).to receive(:perform_later)
    end

    context 'when there is a payment related to the event' do
      context 'when the payment status is requires_confirmation' do
        let(:status) { 'requires_confirmation' }

        it 'updates the payment status' do
          expect { handle }.to change { payment.reload.status }.from('requires_confirmation').to('paid')
        end

        it 'calls the Givings::Payment::AddGivingCauseToBlockchainJob' do
          handle

          expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later)
        end

        it 'calls the PersonPayments::CreateContributionJob' do
          handle

          expect(PersonPayments::CreateContributionJob).to have_received(:perform_later).with(payment)
        end
      end
    end
  end
end
