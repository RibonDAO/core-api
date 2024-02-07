require 'rails_helper'

RSpec.describe 'Api::V1::Tickets::Tickets', type: :request do
  describe 'get /tickets/available' do
    subject(:request) { get '/api/v1/tickets/available', params: { email: user.email } }

    let(:user) { create(:user) }

    before do
      allow(RibonCoreApi).to receive(:redis).and_return(MockRedis.new)
      create_list(:ticket, 10, user:)
    end

    it 'returns the quantity of tickets available for that user' do
      request

      expect(response.body).to eq({ tickets: 10 }.to_json)
    end
  end
end
