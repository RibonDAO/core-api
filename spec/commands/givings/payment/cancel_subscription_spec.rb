# frozen_string_literal: true

require 'rails_helper'

describe Givings::Payment::CancelSubscription do
  describe '.call' do
    subject(:command) { described_class.call(args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when canceling a subscription' do
      let(:subscription) do
        build(:subscription, external_id: 'sub_1Ne15GAvG66WJy8BS3oZ9VGW', cancel_date: nil)
      end
      let(:args) { { subscription: } }

      before do
        allow(Subscription).to receive(:find_by).and_return(subscription)
      end

      it 'calls Service::Givings::Payment::Orchestrator with correct payload' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new)

        command
        expect(Service::Givings::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            subscription:, gateway: 'stripe', operation: 'unsubscribe'
          ))
      end

      it 'calls Service::Givings::Payment::Orchestrator process' do
        orchestrator_double = instance_double(Service::Givings::Payment::Orchestrator, { call: nil })
        allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        command

        expect(orchestrator_double).to have_received(:call)
      end

      context 'when the cancelation is sucessfull' do
        it 'update the status and cancel_date of subscription' do
          command

          expect(subscription.status).to eq('canceled')
          expect(subscription.cancel_date).not_to be_nil
        end
      end
    end
  end
end
