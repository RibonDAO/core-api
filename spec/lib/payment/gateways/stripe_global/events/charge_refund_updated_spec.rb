require 'rails_helper'

RSpec.describe Payment::Gateways::StripeGlobal::Events::ChargeRefundUpdated do
  describe '.handle' do
    subject(:handle) { described_class.handle(event) }

    let(:event) do
      RecursiveOpenStruct.new({ data: { object: { payment_intent: 'external_id' } } })
    end

    context 'when there is a person payment' do
      before do
        create(:person_payment, external_id: 'external_id')
      end

      it 'update the person_payment status' do
        handle
        expect(PersonPayment.last.status).to eq('refund_failed')
      end
    end
  end
end
