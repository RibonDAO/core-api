require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Events::InvoicePaid do
  describe '.handle' do
    subject(:handle) { described_class.handle(event) }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:event) do
      RecursiveOpenStruct.new({ data: { object: { id: 'external_id', subscription: 'external_subscription_id',
                                                  created: 1_691_697_994 } } })
    end

    before do
      allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
      allow(PersonPayments::CreateContributionJob).to receive(:perform_later)
    end

    context 'when there is a new invoice from a subscription' do
      context 'when there is a subscription' do
        before do
          payer = create(:customer)
          receiver = create(:cause)
          create(:subscription, external_id: 'external_subscription_id', payer:, receiver:)
        end

        it 'creates a new person_payment' do
          expect { handle }.to change(PersonPayment, :count).by(1)
        end

        # it 'calls the Givings::Payment::AddGivingCauseToBlockchainJob' do
        #   handle

        #   expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later)
        # end

        it 'calls the PersonPayments::CreateContributionJob' do
          handle

          expect(PersonPayments::CreateContributionJob).to have_received(:perform_later)
        end
      end

      context 'when there is not a subscription' do
        it 'does not create a new person_payment' do
          expect { handle }.not_to change(PersonPayment, :count)
        end
      end
    end
  end
end
