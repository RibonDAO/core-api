# frozen_string_literal: true

require 'rails_helper'

describe Subscriptions::CancelSubscription do
  describe '.call' do
    subject(:command) { described_class.call(subscription_id:) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    let(:subscription) do
      build(:subscription, external_id: 'sub_1Ne15GAvG66WJy8BS3oZ9VGW', cancel_date: nil, offer:)
    end

    let(:subscription_id) { subscription.id }

    before do
      allow(Subscription).to receive(:find_by).and_return(subscription)
    end

    context 'when canceling a subscription on stripe' do
      let(:offer) { create(:offer) }
      let(:gateway) { offer.gateway }

      it 'calls Service::Givings::Payment::Orchestrator with correct payload' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new)

        command
        expect(Service::Givings::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            subscription:, gateway:, operation: 'unsubscribe'
          ))
      end

      it 'calls Service::Givings::Payment::Orchestrator process' do
        orchestrator_double = instance_double(Service::Givings::Payment::Orchestrator, { call: nil })
        allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        command

        expect(orchestrator_double).to have_received(:call)
      end

      context 'when the cancelation is sucessfull' do
        let(:jwt) { 'jwt.webtoken' }
        let(:event_service_double) { instance_double(EventServices::SendEvent) }
        let(:event) do
          OpenStruct.new({
                           name: 'cancel_subscription',
                           data: {
                             receiver_name: subscription.receiver.name,
                             subscription_id: subscription.id,
                             user: subscription.payer.user,
                             amount: person_payment.formatted_amount,
                             token: jwt,
                             status: subscription.status
                           }
                         })
        end
        let(:person_payment) { create(:person_payment, subscription:) }

        before do
          person_payment
          allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
          allow(event_service_double).to receive(:call)
          allow(Jwt::Encoder).to receive(:encode).and_return(jwt)
        end

        it 'update the status and cancel_date of subscription, and send email' do
          command

          expect(subscription.status).to eq('canceled')
          expect(subscription.cancel_date).not_to be_nil
          expect(EventServices::SendEvent).to have_received(:new).with({ user: subscription.payer.user, event: })
        end
      end
    end

    context 'when canceling a subscription on stripe global' do
      let(:offer) { create(:offer, :with_stripe_global) }
      let(:gateway) { offer.gateway }

      it 'calls Service::Givings::Payment::Orchestrator with correct payload' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new)

        command
        expect(Service::Givings::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            subscription:, gateway:, operation: 'unsubscribe'
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
