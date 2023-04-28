require 'rails_helper'

RSpec.describe Payment::Gateways::Stripe::Helpers do
  describe '.status' do
    context 'when the stripe status is succeeded' do
      it 'returns :paid' do
        expect(described_class.status('succeeded')).to eq(:paid)
      end
    end

    context 'when the stripe status is requires_action' do
      it 'returns :requires_action' do
        expect(described_class.status('requires_action'))
          .to eq(:requires_action)
      end
    end

    context 'when the stripe status is processing' do
      it 'returns :processing' do
        expect(described_class.status('processing')).to eq(:processing)
      end
    end

    context 'when the stripe status is canceled' do
      it 'returns :failed' do
        expect(described_class.status('canceled')).to eq(:failed)
      end
    end
  end
end
