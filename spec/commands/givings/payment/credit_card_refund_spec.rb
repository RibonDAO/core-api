# frozen_string_literal: true

require 'rails_helper'

describe Givings::Payment::CreditCardRefund do
  describe '.call' do
    subject(:command) { described_class.call(args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when using a CreditCard payment and refund' do
      let(:offer) { create(:offer) }
      let(:person_payment) do
        build(:person_payment, offer:, amount_cents: 1, external_id: 'pi_123',
                               refund_date: '2022-10-25 12:20:41')
      end
      let(:args) { { external_id: 'pi_123' } }

      before do
        allow(PersonPayment).to receive(:find_by).and_return(person_payment)
      end

      it 'calls Givings::Payment::Orchestrator with correct payload' do
        allow(Givings::Payment::Orchestrator).to receive(:new)
        command
        expect(Givings::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            external_id: person_payment.external_id, gateway: 'stripe',
            operation: 'refund'
          ))
      end

      it 'calls Givings::Payment::Orchestrator process' do
        orchestrator_double = instance_double(Givings::Payment::Orchestrator, { call: nil })
        allow(Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        command

        expect(orchestrator_double).to have_received(:call)
      end

      context 'when the refund is sucessfull' do
        it 'update the status and external_id of person_payment' do
          command
          expect(person_payment.status).to eq('refunded')
          expect(person_payment.refund_date).to eq Time.zone.parse('2022-10-25 12:20:40')
        end
      end
    end
  end
end
