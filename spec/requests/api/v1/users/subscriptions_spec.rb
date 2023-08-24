require 'rails_helper'

RSpec.describe 'Api::V1::Users::Contributions', type: :request do
  describe 'GET /api/v1/users/:user_id/subscriptions' do
    context 'when is successfully cancelled' do
      subject(:request) { get "/api/v1/users/#{user.id}/subscriptions" }

      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:) }
      let!(:person_payment) { create(:person_payment, payer: customer) }
      let(:receiver) { create(:non_profit, :with_impact) }
      let(:subscription) { create(:subscription, person_payments: [person_payment], status: :active) }

      it 'returns all user subscriptions' do
        request
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
