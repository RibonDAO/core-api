require 'rails_helper'

RSpec.describe Crm::Customer::WebhookSignatureValidator do
  subject(:service) { described_class.new(webhook_signing_secret, xcio_signature, xcio_timestamp, request_body) }

  let(:webhook_signing_secret) { 'secret' }

  let(:xcio_signature) do
    'ab36801eb297377400db0ce6bc95045564f10cd7302fd4740f4cc1d8f81d69e4'
  end

  let(:xcio_timestamp) { '1704720412' }

  let(:request_body) do
    response = {
      data: {
        action_id: 42,
        campaign_id: 23,
        content: 'Welcome to Customer.io!',
        customer_id: 'user-123',
        delivery_id: 'RAECAAFwnUSneIa0ZXkmq8EdkAM==',
        identifiers: {
          id: 'user-123'
        },
        recipient: 'test@example.com',
        subject: 'Welcome to Customer.io!'
      },
      event_id: '01E2EMRMM6TZ12TF9WGZN0WJQT',
      object_type: 'email',
      metric: 'sent',
      timestamp: '1704720412'
    }

    response.to_json
  end

  describe '#validate' do
    it 'validates signature' do
      expect(service.validate).to eq('teste')
    end
  end
end
