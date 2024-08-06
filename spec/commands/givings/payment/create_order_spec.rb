# frozen_string_literal: true

require 'rails_helper'

describe Givings::Payment::CreateOrder do
  before do
    allow(PersonPayments::UpdatePaymentAttributeJob).to receive(:perform_later)
    allow(Subscriptions::UpdateSubscriptionAttributeJob).to receive(:perform_later)
  end

  describe '.call' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    let(:integration) { create(:integration) }
    let(:orchestrator_double) do
      instance_double(Service::Givings::Payment::Orchestrator, { call: {
                        status: :paid
                      } })
    end

    context 'when using a CreditCard payment and subscribe' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card) }
      let(:offer) { create(:offer, :subscription) }
      let(:person_payment) { create(:person_payment, offer:, payer: customer, integration:) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, gateway: 'stripe', operation: :subscribe }
      end

      context 'when there is no customer associated with the user' do
        it 'creates a new customer to the user' do
          expect { command }.to change(Customer, :count).by(1)
        end
      end

      it 'creates a PersonPayment' do
        expect { command }.to change(PersonPayment, :count).by(1)
      end

      it 'creates a new subscription' do
        expect { command }.to change(Subscription, :count).by(1)
      end

      it 'calls Service::Givings::Payment::Orchestrator with correct payload' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        allow(PersonPayment).to receive(:create!).and_return(person_payment)
        command

        expect(Service::Givings::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            payment_method: 'credit_card', payment: person_payment,
            status: :paid, card:, offer:, payer: customer
          ))
      end

      it 'calls Service::Givings::Payment::Orchestrator process' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        command

        expect(orchestrator_double).to have_received(:call)
      end

      context 'when the payment is sucessfull' do
        it 'calls the success callback' do
          allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
          allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
          command

          expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later)
            .with(amount: person_payment.crypto_amount, payment: an_object_containing(
              id: person_payment.id, amount_cents: person_payment.amount_cents,
              offer_id: person_payment.offer.id,
              status: person_payment.status, payment_method: person_payment.payment_method
            ), pool: nil)
        end

        it 'update the status of payment_person' do
          command
          person_payment = PersonPayment.where(offer:).last

          expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
            person_payment, { status: :paid }
          )
        end

        it 'update the external_id of payment_person' do
          command
          person_payment = PersonPayment.where(offer:).last

          expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
            person_payment, { external_id: 'pi_1Gt08v2eZvKYlo2CVSyYMu9B' }
          )
          expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
            person_payment, { external_invoice_id: 'in_1LL5lOJuOnwQq9QxgwtucIBS' }
          )
        end

        it 'update the status of subscription and external_id' do
          command
          person_payment = PersonPayment.where(offer:).last
          subscription = person_payment.subscription

          expect(Subscriptions::UpdateSubscriptionAttributeJob).to have_received(:perform_later).once.with(
            subscription, { status: :active }
          )
          expect(Subscriptions::UpdateSubscriptionAttributeJob).to have_received(:perform_later).once.with(
            subscription, { external_id: 'sub_1LL5lOJuOnwQq9Qx4R7A11nz' }
          )
        end

        it 'returns all necessary keys' do
          expect(command.result.to_h.keys).to match_array(%i[external_customer_id external_id
                                                             external_invoice_id external_payment_method_id
                                                             external_subscription_id payment])
        end
      end
    end

    context 'when using a CreditCard payment and purchase' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card) }
      let(:offer) { create(:offer) }
      let(:person_payment) { create(:person_payment, offer:, payer: customer, integration:) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, operation: :purchase }
      end

      context 'when there is no customer associated with the user' do
        it 'creates a new customer to the user' do
          expect { command }.to change(Customer, :count).by(1)
        end
      end

      it 'creates a PersonPayment' do
        expect { command }.to change(PersonPayment, :count).by(1)
      end

      it 'does not create a new subscription' do
        expect { command }.not_to change(Subscription, :count)
      end

      it 'calls Service::Givings::Payment::Orchestrator with correct payload' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        allow(PersonPayment).to receive(:create!).and_return(person_payment)
        command
        expect(Service::Givings::Payment::Orchestrator)
          .to have_received(:new).with(payload: an_object_containing(
            payment_method: 'credit_card', payment: person_payment,
            status: :paid, card:, offer:, payer: customer
          ))
      end

      it 'calls Service::Givings::Payment::Orchestrator process' do
        allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
        command

        expect(orchestrator_double).to have_received(:call)
      end

      context 'when the payment is sucessfull' do
        it 'calls the success callback' do
          allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
          allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
          command

          expect(Givings::Payment::AddGivingCauseToBlockchainJob).to have_received(:perform_later)
            .with(amount: person_payment.crypto_amount, payment: an_object_containing(
              id: person_payment.id, amount_cents: person_payment.amount_cents,
              offer_id: person_payment.offer.id,
              status: person_payment.status, payment_method: person_payment.payment_method
            ), pool: nil)
        end

        it 'call Job to update status and external_id of payment_person' do
          order = command
          person_payment = PersonPayment.where(offer:).last
          expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
            person_payment, { status: :paid }
          )
          expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
            person_payment, { external_id: order.result[:external_id] }
          )
        end
      end

      context 'when the order is to a non profit' do
        let(:non_profit) { create(:non_profit) }
        let(:args) do
          { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:,
            integration_id: integration.id, payment_method: :credit_card,
            user: customer.user, operation: :purchase, non_profit: }
        end

        before do
          create(:ribon_config)
          create(:chain)
        end

        it 'calls the success callback' do
          allow(Givings::Payment::AddGivingNonProfitToBlockchainJob).to receive(:perform_later)
          allow(Service::Givings::Payment::Orchestrator).to receive(:new).and_return(orchestrator_double)
          command

          expect(Givings::Payment::AddGivingNonProfitToBlockchainJob).to have_received(:perform_later)
            .with(amount: person_payment.crypto_amount, payment: an_object_containing(
              id: person_payment.id, amount_cents: person_payment.amount_cents,
              offer_id: person_payment.offer.id, person_id: person_payment.payer.id,
              status: person_payment.status, payment_method: person_payment.payment_method
            ), non_profit:)
        end
      end
    end

    context 'when using a Crypto payment' do
      let(:order_type_class) { Givings::Payment::OrderTypes::Cryptocurrency }
      let(:transaction_hash) { '0xFFFF' }
      let(:crypto_user) { build(:crypto_user) }
      let(:person_payment) { build(:person_payment, offer: nil, payer: crypto_user, integration:) }

      let(:args) do
        { wallet_address: crypto_user.wallet_address, payment_method: :crypto,
          user: nil, amount: '7.00', transaction_hash:, integration_id: integration.id }
      end

      before do
        allow(CryptoUser).to receive(:create!).and_return(crypto_user)
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

  describe '.call returns error with purchase' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method_error' } }

    let(:integration) { create(:integration) }

    context 'when the payment is failed' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card, :invalid) }
      let(:offer) { create(:offer) }
      let(:person_payment) { create(:person_payment, offer:, payer: customer, integration:, amount_cents: 1) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, gateway: 'stripe', operation: :subscribe }
      end

      it 'calls the failure callback' do
        allow(Customer).to receive(:create!).and_return(customer)
        allow(PersonPayment).to receive(:create!).and_return(person_payment)
        command

        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { status: :failed, error_code: 'card_declined' }
        )
      end
    end
  end

  describe '.call returns blocked with purchase' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method_blocked' } }

    let(:integration) { create(:integration) }

    context 'when the payment is blocked' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card, :blocked) }
      let(:offer) { create(:offer, price_cents: 1000) }
      let(:person_payment) { create(:person_payment, offer:, payer: customer, integration:, amount_cents: 1) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, gateway: 'stripe', operation: :purchase }
      end

      it 'calls the failure callback' do
        allow(Customer).to receive(:create!).and_return(customer)
        allow(PersonPayment).to receive(:create!).and_return(person_payment)
        command

        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { status: :blocked, error_code: 'card_declined' }
        )
        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { external_id: 'pi_3NvgHJJuOnwQq9Qx1NiwLdAk' }
        )
      end
    end
  end

  describe '.call returns pending with purchase' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method_pending' } }

    let(:integration) { create(:integration) }

    context 'when the payment returns requires_action' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card, :requires_action) }
      let(:offer) { create(:offer, price_cents: 10_000) }
      let(:person_payment) { create(:person_payment, offer:, payer: customer, integration:, amount_cents: 1) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, operation: :purchase }
      end

      it 'does not call the success callback' do
        allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
        command

        expect(Givings::Payment::AddGivingCauseToBlockchainJob).not_to have_received(:perform_later)
      end

      it 'update the status and external_id of payment_person' do
        command
        person_payment = PersonPayment.where(offer:).last
        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { status: :requires_action }
        )
        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { external_id: 'pi_3NvgHOJuOnwQq9Qx1qaAMaSR' }
        )
      end
    end
  end

  describe '.call returns blocked with subscribe' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method_blocked' } }

    let(:integration) { create(:integration) }

    context 'when the payment is blocked' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card, :blocked) }
      let(:offer) { create(:offer, :subscription) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, gateway: 'stripe', operation: :subscribe }
      end

      it 'does not call the success callback' do
        allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
        command

        expect(Givings::Payment::AddGivingCauseToBlockchainJob).not_to have_received(:perform_later)
      end

      it 'calls the failure callback' do
        command
        person_payment = PersonPayment.where(offer:).last
        subscription = person_payment.subscription

        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { status: :blocked, error_code: 'card_declined' }
        )

        expect(Subscriptions::UpdateSubscriptionAttributeJob).to have_received(:perform_later).once.with(
          subscription, { status: :payment_failed }
        )
      end
    end
  end

  describe '.call returns pending with subscribe' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method_pending' } }

    let(:integration) { create(:integration) }

    context 'when the payment returns requires_action' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card, :requires_action) }
      let(:offer) { create(:offer, :subscription) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, operation: :subscribe }
      end

      it 'does not call the success callback' do
        allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
        command

        expect(Givings::Payment::AddGivingCauseToBlockchainJob).not_to have_received(:perform_later)
      end

      it 'update the status and external_id of payment_person' do
        command
        person_payment = PersonPayment.where(offer:).last

        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { status: :requires_action, error_code: 'requires_action' }
        )
        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { external_id: 'pi_3NvgHSJuOnwQq9Qx0MOWpFIt' }
        )
      end

      it 'update the status of subscription' do
        command
        person_payment = PersonPayment.where(offer:).last
        subscription = person_payment.subscription

        expect(Subscriptions::UpdateSubscriptionAttributeJob).to have_received(:perform_later).once.with(
          subscription, { status: :payment_failed }
        )
      end
    end
  end

  describe '.call returns failed with subscribe' do
    subject(:command) { described_class.call(order_type_class, args) }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method_error' } }

    let(:integration) { create(:integration) }

    context 'when the payment returns failed' do
      let(:order_type_class) { Givings::Payment::OrderTypes::CreditCard }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:card) { build(:credit_card, :invalid) }
      let(:offer) { create(:offer, :subscription) }
      let(:args) do
        { card:, email: 'user@test.com', tax_id: '111.111.111-11', offer:, integration_id: integration.id,
          payment_method: :credit_card, user: customer.user, operation: :subscribe }
      end

      it 'does not call the success callback' do
        allow(Givings::Payment::AddGivingCauseToBlockchainJob).to receive(:perform_later)
        command

        expect(Givings::Payment::AddGivingCauseToBlockchainJob).not_to have_received(:perform_later)
      end

      it 'update the status and external_id of payment_person' do
        command
        person_payment = PersonPayment.where(offer:).last
        subscription = person_payment.subscription

        expect(PersonPayments::UpdatePaymentAttributeJob).to have_received(:perform_later).once.with(
          person_payment, { status: :failed, error_code: 'card_declined' }
        )

        expect(Subscriptions::UpdateSubscriptionAttributeJob).to have_received(:perform_later).once.with(
          subscription, { status: :payment_failed }
        )
      end
    end
  end
end
