require 'rails_helper'

RSpec.describe 'Api::V1::Payments::Subscriptions', type: :request do
  let(:subscription) { create(:subscription) }
  let(:params) { subscription.id }

  describe 'PUT /api/v1/payments/cancel_subscription/:id' do
    subject(:request) { put "/api/v1/payments/cancel_subscription/#{subscription.id}" }

    it 'returns http status ok' do
      request

      expect(response).to have_http_status :ok
    end
  end
end
