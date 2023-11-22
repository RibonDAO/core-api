require 'rails_helper'

RSpec.describe PersonPaymentObserver, type: :observer do
  describe 'if a person payment status change from processing to paid' do
    before do
      allow(Mailers::SendPersonPaymentEmailJob).to receive(:perform_later).with(person_payment:)
      allow(Events::PersonPayments::SendFailedPaymentEventJob).to receive(:perform_later).with(person_payment:)
    end

    %i[credit_card pix google_pay apple_pay].each do |payment_method|
      let(:person_payment) { create(:person_payment, status: :processing, payment_method:) }
      it "calls the mailer job if payment method is #{payment_method}" do
        person_payment.update(status: :paid)
        expect(Mailers::SendPersonPaymentEmailJob).to have_received(:perform_later).with(person_payment:)
      end
    end

    context 'when person payment has a subscription' do
      let(:person_payment) do
        create(:person_payment, status: :processing, payment_method: :credit_card)
      end
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

    context 'when it is a crypto method' do
      let(:person_payment) do
        create(:person_payment, status: :processing, payment_method: :crypto)
      end

      it 'do not call the mailer job' do
        person_payment.update(status: :paid)
        expect(Mailers::SendPersonPaymentEmailJob).not_to have_received(:perform_later).with(person_payment:)
      end
    end
  end
end
