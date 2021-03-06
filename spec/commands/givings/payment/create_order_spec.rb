# frozen_string_literal: true

require 'rails_helper'

describe Givings::Payment::CreateOrder do
  describe '.call' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    let(:person) { create(:person) }

    context 'when using a CreditCard payment' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:customer) { build(:customer, person:, user: create(:user)) }
      let(:card) { build(:credit_card) }
      let(:offer) { create(:offer) }
      let(:person_payment) { build(:person_payment, offer:, person:, amount_cents: 1) }

      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:,
          payment_method: :credit_card, user: customer.user, operation: :subscribe }
      end

      context 'when there is no customer associated with the user' do
        it 'creates a new customer to the user' do
          expect { command }.to change(Customer, :count).by(1)
        end
      end

      it 'creates a PersonPayment' do
        expect { command }.to change(PersonPayment, :count).by(1)
      end

      it 'calls GivingServices::Payment::Orchestrator with correct payload' do
        allow(GivingServices::Payment::Orchestrator).to receive(:new)
        allow(Person).to receive(:create!).and_return(person)
        allow(Customer).to receive(:create!).and_return(customer)
        allow(PersonPayment).to receive(:create!).and_return(person_payment)
        command

        expect(GivingServices::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            payment_method: 'credit_card', payment: person_payment,
            status: :paid, card:, offer:, person:
          ))
      end

      it 'calls GivingServices::Payment::Orchestrator process' do
        orchestrator_double = instance_double(GivingServices::Payment::Orchestrator, { call: nil })
        allow(GivingServices::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        command

        expect(orchestrator_double).to have_received(:call)
      end

      context 'when the payment is sucessfull' do
        it 'calls the success callback' do
          allow(Givings::Payment::AddGivingToBlockchainJob).to receive(:perform_later)
          orchestrator_double = instance_double(GivingServices::Payment::Orchestrator, { call: nil })
          allow(GivingServices::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
          command

          expect(Givings::Payment::AddGivingToBlockchainJob).to have_received(:perform_later)
            .with(amount: person_payment.crypto_amount, payment: an_object_containing(
              id: person_payment.id, amount_cents: person_payment.amount_cents,
              offer_id: person_payment.offer.id, person_id: person_payment.person.id,
              status: person_payment.status, payment_method: person_payment.payment_method
            ))
        end
      end
    end

    context 'when using a Crypto payment' do
      let(:order_type_class) { Givings::Payment::OrderTypes::Cryptocurrency }
      let(:transaction_hash) { '0xFFFF' }
      let(:person_payment) { build(:person_payment, offer: nil, person:) }
      let(:guest) { build(:guest, person:) }

      let(:args) do
        { wallet_address: guest.wallet_address, payment_method: :crypto,
          user: nil, amount: '7.00', transaction_hash: }
      end

      before do
        allow(Person).to receive(:create!).and_return(person)
        allow(Guest).to receive(:create!).and_return(guest)
        allow(PersonPayment).to receive(:create!).and_return(person_payment)
      end

      it 'creates a PersonPayment' do
        expect { command }.to change(PersonPayment, :count).by(1)
      end

      it 'creates a PersonBlockchainTransaction' do
        expect { command }.to change(PersonBlockchainTransaction, :count).by(1)
      end
    end
  end
end
