require 'rails_helper'

RSpec.describe 'Api::V1::Subscriptions::Subscriptions', type: :request do
  let(:subscription) { create(:subscription) }
  let(:params) { subscription.id }
  let(:create_order_command_double) do
    command_double(klass: Subscriptions::CancelSubscription)
  end

  before do
    allow(Subscriptions::CancelSubscription).to receive(:call).and_return(create_order_command_double)
  end

  describe 'PUT /api/v1/subscriptions/cancel_subscription/:id' do
    context 'when is successfully cancelled' do
      subject(:request) { put "/api/v1/subscriptions/cancel_subscription/#{subscription.id}" }

      let(:create_order_command_double) do
        command_double(klass: Subscriptions::CancelSubscription, success: true)
      end

      it 'returns http status ok' do
        request

        expect(response).to have_http_status :ok
      end
    end

    context 'when command returns error' do
      subject(:request) { put "/api/v1/subscriptions/cancel_subscription/#{subscription.id}" }

      let(:create_order_command_double) do
        command_double(klass: Subscriptions::CancelSubscription, success: false)
      end

      it 'returns http status unprocessable entity' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
