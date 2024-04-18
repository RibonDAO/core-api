require 'rails_helper'

RSpec.describe Vouchers::WebhookJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(voucher) }

    let(:voucher) { build(:voucher, integration:) }
    let(:integration) { build(:integration, integration_webhook:) }
    let(:integration_webhook) { build(:integration_webhook, url: 'http://example.url') }

    before do
      allow(Request::ApiRequest).to receive(:post).and_return(OpenStruct.new({ ok?: ok }))
    end

    context 'when the request returns a response success' do
      let(:ok) { true }

      it 'calls the api request with correct params' do
        perform_job

        expect(Request::ApiRequest).to have_received(:post).with('http://example.url',
                                                                 body: VoucherBlueprint.render(voucher))
      end
    end

    context 'when the request returns a response failure' do
      let(:ok) { false }

      it 'raises a webhook failed error' do
        expect { perform_job }.to raise_error(StandardError, 'webhook failed')
      end
    end
  end
end
