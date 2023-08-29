require 'rails_helper'

RSpec.describe 'Api::V1::Users::Subscriptions', type: :request do
  describe 'GET /api/v1/users/:user_id/subscriptions' do
    context 'when successfully get user subscriptions' do
      subject(:request) { get '/api/v1/users/subscriptions', headers: { Email: user.email } }

      include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:person_payment) { create(:person_payment, payer: customer) }
      let(:subscription) do
        create(:subscription, person_payments: [person_payment], status: :active, payer: customer)
      end

      before do
        subscription
      end

      it 'returns all user subscriptions' do
        request
        expect(response).to have_http_status(:ok)
        expect_response_collection_to_have_keys(%w[id status cancel_date created_at offer receiver
                                                   person_payments])
      end
    end
  end

  describe 'POST /api/v1/users/send_cancel_subscription_email' do
    context 'when successfully send cancel subscription email' do
      subject(:request) do
        post '/api/v1/users/send_cancel_subscription_email', params: { subscription_id: subscription.id }
      end

      include_context('when mocking a request') do
        let(:cassette_name) do
          'send_event_customer_cancel_subscription'
        end
      end
      let(:user) { create(:user, email: 'user151@example.com') }
      let(:customer) { create(:customer, user:) }
      let(:person_payment) { create(:person_payment, payer: customer, subscription:) }
      let(:subscription) { create(:subscription, payer: customer) }

      before do
        person_payment
      end

      it 'send request successfully' do
        request

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ message: 'Email sent' }.to_json)
      end
    end
  end
end
