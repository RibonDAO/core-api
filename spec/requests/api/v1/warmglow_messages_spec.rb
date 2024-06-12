require 'rails_helper'

RSpec.describe 'Api::V1::WarmglowMessagesController', type: :request do
  describe 'GET /random_message' do
    subject(:request) { get '/api/v1/warmglow_messages/random_message' }

    context 'when there are active warmglow messages' do
      let(:warmglow_message) { create(:warmglow_message, status: :active) }

      it 'returns a random active warmglow message' do
        request

        expect(response).to have_http_status(:ok)
       expect_response_to_have_keys(%w[message])
      end
    end

    context 'when there are no active warmglow messages' do
      it 'returns the default message' do
        request

        expect(response).to have_http_status(:ok)
       expect_response_to_have_keys(%w[message])
      end
    end
  end
end
