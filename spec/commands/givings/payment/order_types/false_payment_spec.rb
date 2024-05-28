require 'rails_helper'

describe Givings::Payment::OrderTypes::FalsePayment do
  describe '.call' do
    subject(:command) { described_class.new(args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when it is a club subscription' do
      let(:integration) { create(:integration) }
      let(:offer) { create(:offer) }
      let(:args) do
        { email: 'user@test.com', offer:, name: 'teste', integration_id: integration.id }
      end

      it 'creates a subscription with receiver nil' do
        command.call
        expect(Subscription.last.receiver).to be_nil
      end
    end
  end
end
