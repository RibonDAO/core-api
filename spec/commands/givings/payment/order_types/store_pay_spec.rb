# frozen_string_literal: true

require 'rails_helper'

describe Givings::Payment::OrderTypes::StorePay do
  describe '.call' do
    subject(:command) { described_class.new(args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }
    let(:integration) { create(:integration) }
    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:payment_method_id) { 'ndkdniwe2m2dw' }

    context 'when it is a club subscription' do
      let!(:cause) { create(:cause, status: :active) }
      let(:offer) { create(:offer, :subscription, category: :club) }
      let(:args) do
        { payment_method_id:, email: 'user@test.com', tax_id: '111.111.111-11',
          offer:, integration_id: integration.id,
          payment_method_type: :google_pay, user: customer.user,
          gateway: 'stripe', operation: :subscribe, cause: }
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

    context 'when it is a ngo subscription' do
      let!(:non_profit) { create(:non_profit, status: :active) }
      let(:offer) { create(:offer, :subscription, category: :direct_contribution) }
      let(:args) do
        { payment_method_id:, email: 'user@test.com', tax_id: '111.111.111-11',
          offer:, integration_id: integration.id,
          payment_method_type: :google_pay, user: customer.user,
          gateway: 'stripe', operation: :subscribe, non_profit: }
      end

      it 'creates a subscription with receiver nil' do
        command.generate_order
        expect(Subscription.last.receiver).to eq(non_profit)
      end

      it 'creates a person payment with receiver that is a sample from causes' do
        command.generate_order
        expect(PersonPayment.last.receiver).to eq(non_profit)
      end
    end
  end
end
