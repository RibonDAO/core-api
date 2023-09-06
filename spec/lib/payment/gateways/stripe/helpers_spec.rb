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

  describe '.raise_card_error' do
    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }
    let(:card_error) { Payment::Gateways::Stripe::CardErrors }

    context 'when the stripe error has a charge' do
      let!(:stripe_error) do
        RecursiveOpenStruct.new({ error: {  charge: 'ch_3NnLspAvG66WJy8B0dFmDBcf',
                                            code: 'code',
                                            message: 'message',
                                            type: 'type' } })
      end
      let(:charge) do
        RecursiveOpenStruct.new({ payment_intent: 'pi_3NnLspAvG66WJy8B0dFmDBcf',
                                  outcome: { type: 'type' } })
      end

      before do
        allow(::Stripe::Charge).to receive(:retrieve).and_return(charge)
      end

      it 'raises a Stripe::CardErrors' do
        expect do
          described_class.raise_card_error(stripe_error)
        end.to raise_error(an_instance_of(card_error).and(having_attributes(
                                                            message: 'message',
                                                            code: 'code',
                                                            type: 'type',
                                                            external_id: 'pi_3NnLspAvG66WJy8B0dFmDBcf'
                                                          )))
      end
    end

    context 'when the stripe error does not have a charge' do
      let!(:stripe_error) do
        RecursiveOpenStruct.new({ error: {  request_log_url: 'https://request-log-url.com',
                                            code: 'code',
                                            message: 'message',
                                            type: 'type' } })
      end

      it 'raises a Stripe::CardErrors' do
        expect do
          described_class.raise_card_error(stripe_error)
        end.to raise_error(an_instance_of(card_error).and(having_attributes(message: 'message',
                                                                            code: 'code',
                                                                            type: 'type',
                                                                            external_id: 'https://request-log-url.com')))
      end
    end
  end
end
