require 'rails_helper'
require 'json'

RSpec.describe 'Managers::V1::SubscriptionsController', type: :request do
  describe 'POST /create_direct_transfer_subscriptions' do
    subject(:request) { post '/managers/v1/subscriptions/create_direct_transfer_subscriptions', params: }

    let(:offer) { create(:offer) }
    let(:integration) { create(:integration) }
    let(:csv_content) { "email\r\nclara@ribon.io\r\nclara+1@ribon.io\r\nclara+3@ribon.io" }
    let(:params) { { csv_content:, offer_id: offer.id, integration_id: integration.id } }

    context 'when the parameters are correct' do
      it 'returns success status' do
        create(:plan, offer:)
        request
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the offer does not have a plan' do
      it 'returns unprocessable entity status' do
        request
        json_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_body['message']).to include('Offer not found or does not have a plan')
      end
    end

    context 'when one user already has an active subscription' do
      it 'does not create a new one for them' do
        create(:plan, offer:)
        create(:subscription, payer: create(:customer, user: create(:user, email: 'clara@ribon.io')))
        expect { request }.to change(Subscription, :count).by(2)
      end
    end
  end
end
