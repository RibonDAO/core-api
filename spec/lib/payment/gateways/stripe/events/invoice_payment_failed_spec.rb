require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Events::InvoicePaymentFailed do
  describe '.handle' do
    subject(:handle) { described_class.handle(event) }

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

    let(:event) do
      RecursiveOpenStruct.new({ data: { object: { id: 'external_invoice_id',
                                                  subscription: 'external_subscription_id',
                                                  created: 1_691_697_994,
                                                  payment_intent: 'external_id' } } })
    end

    context 'when there is a subscription' do
      let!(:payer) { create(:customer) }
      let!(:subscription) { create(:subscription, external_id: 'external_subscription_id', payer:) }

      it 'creates a new person_payment with status failed' do
        expect { handle }.to change(PersonPayment, :count).by(1)
        expect(PersonPayment.last.status).to eq('failed')
      end

      describe 'and a person_payment' do
        before do
          create(:person_payment, external_invoice_id: 'external_invoice_id', subscription:, status: :processing)
        end

        it 'does not create a new person_payment' do
          expect { handle }.not_to change(PersonPayment, :count)
        end

        it 'updates the person_payment status' do
          expect { handle }.to change { PersonPayment.last.status }.to('failed')
        end

        it 'updates the person_payment external_id' do
          expect { handle }.to change { PersonPayment.last.external_id }.to('external_id')
        end
      end
    end

    context 'when there is not a subscription' do
      it 'does not create a new person_payment' do
        expect { handle }.not_to change(PersonPayment, :count)
      end
    end

    context 'when there is a subscription from club' do
      let!(:cause) { create(:cause, status: :active) }
      let!(:offer) { create(:offer, category: :club) }
      let!(:payer) { create(:customer) }
      let!(:subscription) do
        create(:subscription, external_id: 'external_subscription_id', payer:, offer:, receiver: nil)
      end

      it 'saves a sample cause on person payment receiver' do
        handle
        expect(subscription.person_payments.last.receiver).to eq(cause)
      end
    end
  end
end
