require 'rails_helper'

RSpec.describe PersonPaymentObserver, type: :observer do
  describe 'if a person payment credit card method id updated and status change from processing to paid' do
    let(:person_payment) { create(:person_payment, status: :processing, payment_method: :credit_card) }

    before do
      allow(Mailers::SendPersonPaymentEmailJob).to receive(:perform_later).with(person_payment:)
    end

    it 'calls the mailer job' do
      person_payment.update(status: :paid)
      expect(Mailers::SendPersonPaymentEmailJob).to have_received(:perform_later).with(person_payment:)
    end
  end
end
