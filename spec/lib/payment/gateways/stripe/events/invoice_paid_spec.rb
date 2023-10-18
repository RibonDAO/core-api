require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Events::InvoicePaid do
  describe '.handle' do
    subject(:handle) { described_class.new.handle(event) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    let(:event) do
      RecursiveOpenStruct.new({ data: { object: { id: 'external_invoice_id',
                                                  subscription: 'external_subscription_id',
                                                  customer: 'cus_9s6XKzkNRiz8i3',
                                                  created: 1_691_697_994,
                                                  payment_intent: 'external_id' } } })
    end

    before do
      allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
      allow(Givings::Payment::AddGivingNonProfitToBlockchainJob).to receive(:perform_later)
      allow(PersonPayments::CreateContributionJob).to receive(:perform_later)
    end

    context 'when there is a subscription' do
      let!(:payer) { create(:customer) }
      let!(:subscription) { create(:subscription, external_id: 'external_subscription_id', payer:) }

      it 'updates the next payment attempt' do
        handle
        expect(subscription.reload.next_payment_attempt).to eq(Time.zone.at(1_697_054_105))
      end

      it 'updates the status' do
        handle
        expect(subscription.reload.status).to eq('active')
      end

      it 'creates a new person_payment' do
        expect { handle }.to change(PersonPayment, :count).by(1)
      end

      it 'calls the PersonPayments::CreateContributionJob' do
        handle

        expect(PersonPayments::CreateContributionJob).to have_received(:perform_later)
      end

      describe 'and a person_payment' do
        before do
          create(:person_payment, external_invoice_id: 'external_invoice_id', subscription:, status: :processing)
        end

        it 'does not create a new person_payment' do
          expect { handle }.not_to change(PersonPayment, :count)
        end

        it 'updates the person_payment status' do
          expect { handle }.to change { PersonPayment.last.status }.to('paid')
        end

        it 'updates the person_payment external_id' do
          expect { handle }.to change { PersonPayment.last.external_id }.to('external_id')
        end

        it 'calls the PersonPayments::CreateContributionJob' do
          handle

          expect(PersonPayments::CreateContributionJob).to have_received(:perform_later)
        end
      end

      describe 'and a person_payment and a person_blockchain_transaction succeed' do
        let!(:person_payment) do
          create(:person_payment, external_invoice_id: 'external_invoice_id', subscription:, status: :processing)
        end

        before do
          create(:person_blockchain_transaction, person_payment:, treasure_entry_status: :success)
        end

        it 'does not call the Givings::Payment::AddGivingCauseToBlockchainJob' do
          handle

          expect(Givings::Payment::AddGivingCauseToBlockchainJob).not_to have_received(:perform_later)
        end
      end

      describe 'and a person_payment and a contribution' do
        let!(:person_payment) do
          create(:person_payment, external_invoice_id: 'external_invoice_id', subscription:, status: :processing)
        end

        before do
          create(:contribution, person_payment:)
        end

        it 'does not call the PersonPayments::CreateContributionJob' do
          handle
          expect(PersonPayments::CreateContributionJob).not_to have_received(:perform_later)
        end
      end
    end

    context 'when the subscription is for a cause' do
      let!(:payer) { create(:customer) }
      let!(:receiver) { create(:cause) }

      before do
        create(:subscription, external_id: 'external_subscription_id', payer:, receiver:)
      end

      it 'calls the Givings::Payment::AddGivingCauseToBlockchainJob' do
        handle

        expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later)
      end
    end

    context 'when the subscription is for a nonprofit' do
      let!(:payer) { create(:customer) }
      let!(:receiver) { create(:non_profit) }

      before do
        create(:subscription, external_id: 'external_subscription_id', payer:, receiver:)
      end

      it 'calls the Givings::Payment::AddGivingNonProfitToBlockchainJob' do
        handle

        expect(Givings::Payment::AddGivingNonProfitToBlockchainJob).to have_received(:perform_later)
      end
    end

    context 'when there is not a subscription' do
      it 'does not create a new person_payment' do
        expect { handle }.not_to change(PersonPayment, :count)
      end

      it 'does not call the Givings::Payment::AddGivingCauseToBlockchainJob' do
        handle

        expect(Givings::Payment::AddGivingCauseToBlockchainJob).not_to have_received(:perform_later)
      end

      it 'does not call the Givings::Payment::AddGivingNonProfitToBlockchainJob' do
        handle

        expect(Givings::Payment::AddGivingNonProfitToBlockchainJob).not_to have_received(:perform_later)
      end

      it 'does not call the PersonPayments::CreateContributionJob' do
        handle

        expect(PersonPayments::CreateContributionJob).not_to have_received(:perform_later)
      end
    end
  end
end
