require 'rails_helper'

RSpec.describe Crm::Customer::WebhookSignatureValidator do
  subject(:service) { described_class.new(webhook_signing_secret, xcio_signature, xcio_timestamp, request_body) }

  let(:webhook_signing_secret) { 'secret' }

  let(:xcio_signature) do
    'c31b27d93c80cce95c23dc4ec6e7c9e9b755ad0d8c36ab0d0691fb1c3f7b63e3'
  end

  let(:xcio_timestamp) { '1704720412' }

  let(:request_body) do
    file = Rails.root.join('spec/support/webhooks/customerio/email_unsubscribed.json').read

    JSON.parse(file).to_json
  end

  describe '#validate' do
    it 'validates signature' do
      expect(service.validate).to be_truthy
    end
  end
end
