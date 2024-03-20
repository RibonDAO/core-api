require 'rails_helper'

RSpec.describe 'Users::V1::Subscriptions', type: :request do
  describe 'GET /users/v1/subscriptions' do
    context 'when successfully get user subscriptions' do
      include_context 'when making a user request' do
        subject(:request) { get '/users/v1/subscriptions', headers: }
      end

      include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

      let(:user) { account.user }
      let(:customer) { create(:customer, user:) }
      let!(:subscription) { create(:subscription, status: :active, payer: customer) }
      let(:person_payment) { create(:person_payment, payer: customer, subscription:) }

      it 'returns all user subscriptions' do
        request
        expect(response).to have_http_status(:ok)
        expect_response_collection_to_have_keys(%w[id status cancel_date created_at
                                                   next_payment_attempt offer receiver
                                                   person_payments])
      end
    end
  end

  describe 'POST /users/v1/send_cancel_subscription_email' do
    context 'when successfully send cancel subscription email' do
      include_context 'when making a user request' do
        subject(:request) do
          post '/users/v1/send_cancel_subscription_email', headers:, params: { subscription_id: subscription.id }
        end
      end

      include_context('when mocking a request') do
        let(:cassette_name) do
          'send_event_customer'
        end
      end
      let(:user) { account.user }
      let(:customer) { create(:customer, user:) }
      let!(:subscription) { create(:subscription, payer: customer) }
      let(:person_payment) { create(:person_payment, payer: customer, subscription:) }

      it 'send request successfully' do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ message: 'Email sent' }.to_json)
      end
    end
  end
end
