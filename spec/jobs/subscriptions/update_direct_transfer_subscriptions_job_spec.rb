require 'rails_helper'

RSpec.describe Subscriptions::UpdateDirectTransferSubscriptionsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    let(:command) { Subscriptions::UpdateNextPaymentAttempt }
    let!(:subscription1) do
      create(:subscription, status: :active, payment_method: :direct_transfer,
                            next_payment_attempt: Time.zone.today)
    end
    let!(:subscription2) do
      create(:subscription, status: :active, payment_method: :direct_transfer, next_payment_attempt: 1.month.ago)
    end
    let!(:subscription3) do
      create(:subscription, status: :active, payment_method: :pix, next_payment_attempt: Time.zone.today)
    end
    let!(:subscription4) do
      create(:subscription, status: :inactive, payment_method: :direct_transfer,
                            next_payment_attempt: Time.zone.today)
    end

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls UpdateNextPaymentAttempt for subscription1' do
      expect(command).to have_received(:call).with(subscription: subscription1)
    end

    it 'does not call UpdateNextPaymentAttempt for subscription2' do
      expect(command).not_to have_received(:call).with(subscription: subscription2)
    end

    it 'does not call UpdateNextPaymentAttempt for subscription3' do
      expect(command).not_to have_received(:call).with(subscription: subscription3)
    end

    it 'does not call UpdateNextPaymentAttempt for subscription4' do
      expect(command).not_to have_received(:call).with(subscription: subscription4)
    end
  end
end
