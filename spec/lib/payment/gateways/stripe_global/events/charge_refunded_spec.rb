require 'rails_helper'

RSpec.describe Payment::Gateways::StripeGlobal::Events::ChargeRefunded do
  describe '.handle' do
    subject(:handle) { described_class.handle(event) }

    let(:event) do
      RecursiveOpenStruct.new({ data: { object: { payment_intent: 'external_id',
                                                  created: 1_691_697_994 } } })
    end

    context 'when there is a person payment' do
      before do
        create(:person_payment, external_id: 'external_id')
      end

      it 'update the person_payment status' do
        handle
        expect(PersonPayment.last.status).to eq('refunded')
      end

      it 'update the person_payment refund_date' do
        handle
        expect(PersonPayment.last.refund_date).to eq(Time.zone.at(1_691_697_994))
      end
    end

    context 'when there is a person payment with subscription' do
      let!(:subscription) { create(:subscription) }

      before do
        allow(::Givings::Subscriptions::CancelSubscription).to receive(:call)
          .and_return(OpenStruct.new({ success?: true }))
        create(:person_payment, external_id: 'external_id', subscription:)
      end

      it 'update the person_payment status' do
        handle
        expect(PersonPayment.last.status).to eq('refunded')
      end

      it 'update the person_payment refund_date' do
        handle
        expect(PersonPayment.last.refund_date).to eq(Time.zone.at(1_691_697_994))
      end

      it 'calls the command to cancel subscription' do
        handle
        expect(::Givings::Subscriptions::CancelSubscription).to have_received(:call)
          .with(subscription_id: subscription.id)
      end

      it 'cancel the subscription' do
        handle
        expect(subscription.reload.status).to eq('canceled')
      end
    end
  end
end
