require 'rails_helper'

describe Givings::Payment::OrderTypes::Pix do
  describe '.call' do
    subject(:command) { described_class.new(args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when it is a club subscription' do
      let!(:cause) { create(:cause, status: :active) }
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:offer) { create(:offer, :subscription, category: :club) }
      let(:args) do
        { email: 'user@test.com', tax_id: '111.111.111-11', offer:,
          integration_id: integration.id, payment_method: :pix,
          user: customer.user,
          cause: }
      end

      it 'creates a subscription with receiver nil' do
        command.generate_order
        expect(Subscription.last.receiver).to be_nil
      end

      it 'creates a person payment with receiver that is a sample from causes' do
        command.generate_order
        expect(PersonPayment.last.receiver).to eq(cause)
      end
    end
  end
end
