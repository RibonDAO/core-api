# frozen_string_literal: true

require 'rails_helper'

describe Subscriptions::UpdateNextPaymentAttempt do
  describe '.call' do
    subject(:command) { described_class.call(subscription:) }

    let(:subscription) { create(:subscription) }

    context 'when no error occurs' do
      it 'returns the result' do
        expect(command.result).to be_truthy
      end

      it 'updates the subscription next payment attempt to next month' do
        command
        expect(subscription.next_payment_attempt.to_date).to eq 1.month.from_now.to_date
      end
    end
  end
end
