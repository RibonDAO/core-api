require 'rails_helper'

RSpec.describe PersonPaymentObserver, type: :observer do
  describe 'if a person payment credit card method id updated and status change from processing to paid' do
    let(:person_payment) do
      create(:person_payment, status: :processing, payment_method: :credit_card)
    end

    before do
      allow(Mailers::SendPersonPaymentEmailJob).to receive(:perform_later).with(person_payment:)
      allow(Events::PersonPayments::SendFailedPaymentEventJob).to receive(:perform_later).with(person_payment:)
    end

    context 'when person payment has no subscription' do
      it 'calls the mailer job' do
        person_payment.update(status: :paid)
        expect(Mailers::SendPersonPaymentEmailJob).to have_received(:perform_later).with(person_payment:)
      end

      it 'does not call the event job' do
        expect(Events::PersonPayments::SendFailedPaymentEventJob)
          .not_to have_received(:perform_later).with(person_payment:)
      end
    end

    context 'when person payment has a subscription' do
      let(:subscription) { create(:subscription) }

      before { person_payment.update(subscription:) }

      it 'does not call the mailer job' do
        person_payment.update(status: :paid)
        expect(Mailers::SendPersonPaymentEmailJob).not_to have_received(:perform_later).with(person_payment:)
      end

      it 'calls the event job' do
        person_payment.update(status: :failed)
        expect(Events::PersonPayments::SendFailedPaymentEventJob).to have_received(:perform_later)
          .with(person_payment:)
      end
    end
  end
end
