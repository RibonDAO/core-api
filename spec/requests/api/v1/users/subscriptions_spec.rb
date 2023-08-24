require 'rails_helper'

RSpec.describe 'Api::V1::Users::Subscriptions', type: :request do
  describe 'GET /api/v1/users/:user_id/subscriptions' do
    context 'when is successfully get user subscriptions' do
      subject(:request) { get "/api/v1/users/#{user.id}/subscriptions" }

      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let(:person_payment) { create(:person_payment, payer: customer) }
      let(:subscription) do
        create(:subscription, person_payments: [person_payment], status: :active, payer: customer)
      end

      before do
        subscription
        request
      end

      it 'returns all user subscriptions' do
        expect(response).to have_http_status(:ok)
        expect_response_collection_to_have_keys(%w[id status cancel_date created_at offer receiver])
      end
    end
  end
end
