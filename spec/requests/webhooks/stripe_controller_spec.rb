require 'rails_helper'

RSpec.describe 'Webhooks::Stripe', type: :request do
  describe '/webhooks/stripe' do
    subject(:request) { post '/webhooks/stripe', params: event_params }

    context 'when it is not a request from stripe' do
      let(:event_params) do
        file = Rails.root.join('spec/support/webhooks/stripe/refunded.json').read
        JSON.parse file
      end

      it 'returns :forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when it is a request from stripe' do
      let(:person_payment) do
        create(:person_payment, external_id: event_params.dig('data', 'object', 'payment_intent'))
      end

      before do
        person_payment
        allow(::Stripe::Webhook).to receive(:construct_event).and_return(RecursiveOpenStruct.new(event_params))
      end

      context 'and it is a charge.refunded type request' do
        let(:event_params) do
          file = Rails.root.join('spec/support/webhooks/stripe/refunded.json').read
          JSON.parse file
        end

        it 'updates the status of person payment' do
          request
          expect(person_payment.reload.status).to eq('refunded')
        end
      end

      context 'and it is a charge.refund.update type request' do
        let(:event_params) do
          file = Rails.root.join('spec/support/webhooks/stripe/refund_update.json').read
          JSON.parse file
        end

        it 'updates the status of person payment' do
          request
          expect(person_payment.reload.status).to eq('refund_failed')
        end
      end
    end
  end
end
