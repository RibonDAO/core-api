require 'rails_helper'

describe Givings::Payment::OrderTypes::DirectTransfer do
  describe '.call' do
    subject(:command) { described_class.new(args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when it is a club subscription' do
      let(:integration) { create(:integration) }
      let(:offer) { create(:offer) }
      let(:args) do
        { email: 'user@test.com', offer:, integration_id: integration.id }
      end

      it 'creates a subscription' do
        command.call
        expect(Subscription.last.id).not_to be_nil
      end

      it 'creates a person payment' do
        command.call
        expect(PersonPayment.last.id).not_to be_nil
      end
    end
  end
end
