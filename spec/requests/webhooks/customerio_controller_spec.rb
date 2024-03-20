require 'rails_helper'

RSpec.describe 'Webhooks::Customerio', type: :request do
  describe '/webhooks/customerio' do
    subject(:request) { post '/webhooks/customerio', params: event_params, headers: }

    let!(:headers) do
      {
        'X-Cio-Signature': 'c31b27d93c80cce95c23dc4ec6e7c9e9b755ad0d8c36ab0d0691fb1c3f7b63e3',
        'X-Cio-Timestamp': '1704720412'
      }
    end

    context 'when it is not a request from customer' do
      let(:event_params) do
        file = Rails.root.join('spec/support/webhooks/customerio/email_unsubscribed.json').read
        JSON.parse(file).to_json
      end

      it 'returns :forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when it is a request from customer' do
      let(:validator) { instance_double(Crm::Customer::WebhookSignatureValidator) }
      let(:command) { instance_double(Users::UnsubscribeFromEmails) }

      let(:user_config) { build(:user_config, allowed_email_marketing: true) }

      let!(:user) { create(:user, email: 'test@example.com', user_config:) }

      before do
        allow(Crm::Customer::WebhookSignatureValidator).to receive(:new).and_return(validator)
        allow(validator).to receive(:validate).and_return(true)
        allow(Users::UnsubscribeFromEmails).to receive(:call).and_return(command)
      end

      context 'when it is a email unsubscribed event' do
        let(:event_params) do
          file = Rails.root.join('spec/support/webhooks/customerio/email_unsubscribed.json').read
          JSON.parse(file).to_json
        end

        it 'returns :ok' do
          request
          expect(response).to have_http_status :ok
        end

        it 'calls Users::UnsubscribeFromEmails' do
          request
          expect(Users::UnsubscribeFromEmails).to have_received(:call).with(email: user.email)
        end
      end

      context 'when it is a email dropped (supressed) event' do
        let(:event_params) do
          file = Rails.root.join('spec/support/webhooks/customerio/email_dropped.json').read
          JSON.parse(file).to_json
        end

        it 'returns :ok' do
          request
          expect(response).to have_http_status :ok
        end

        it 'calls Users::UnsubscribeFromEmails' do
          request
          expect(Users::UnsubscribeFromEmails).to have_received(:call).with(email: user.email)
        end
      end

      context 'when it is a email spammed event' do
        let(:event_params) do
          file = Rails.root.join('spec/support/webhooks/customerio/email_spammed.json').read
          JSON.parse(file).to_json
        end

        it 'returns :ok' do
          request
          expect(response).to have_http_status :ok
        end

        it 'calls Users::UnsubscribeFromEmails' do
          request
          expect(Users::UnsubscribeFromEmails).to have_received(:call).with(email: user.email)
        end
      end

      context 'when it is a email failed event' do
        let(:event_params) do
          file = Rails.root.join('spec/support/webhooks/customerio/email_failed.json').read
          JSON.parse(file).to_json
        end

        it 'returns :ok' do
          request
          expect(response).to have_http_status :ok
        end

        it 'calls Users::UnsubscribeFromEmails' do
          request
          expect(Users::UnsubscribeFromEmails).to have_received(:call).with(email: user.email)
        end
      end
    end
  end
end
