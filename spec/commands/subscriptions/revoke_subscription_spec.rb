# frozen_string_literal: true

require 'rails_helper'

describe Subscriptions::RevokeSubscription do
  describe '.call' do
    subject(:command) { described_class.call(subscription:) }

    let(:subscription) { create(:subscription, status: :active) }

    context 'when no error occurs' do
      it 'returns the result' do
        expect(command.result).to be_truthy
      end

      it 'updates the subscription status to inactive' do
        command
        expect(subscription.status).to eq 'inactive'
      end
    end
  end
end
