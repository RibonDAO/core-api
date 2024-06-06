require 'rails_helper'

describe Givings::Subscriptions::CreateDirectTransferSubscription do
  describe '.call' do
    subject(:command) { described_class.new(args).call }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when it is a club subscription' do
      let(:integration) { create(:integration) }
      let(:offer) { create(:offer) }
      let(:args) do
        { email: 'user@test.com', offer:, integration_id: integration.id }
      end

      it 'creates a subscription' do
        expect { command }.to change(Subscription, :count).by(1)
      end
    end
  end
end
