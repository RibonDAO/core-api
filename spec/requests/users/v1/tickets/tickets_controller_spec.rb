require 'rails_helper'

RSpec.describe 'Users::V1::Tickets::Tickets', type: :request do
  describe 'get /tickets/available' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/tickets/available', headers: }
    end

    before do
      allow(RibonCoreApi).to receive(:redis).and_return(MockRedis.new)
      create_list(:ticket, 10, user: account.user)
    end

    it 'returns the quantity of tickets available for that user' do
      request

      expect(response.body).to eq({ tickets: 10 }.to_json)
    end
  end

  describe 'get /tickets/to_collect' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/tickets/to_collect', headers:, params: { source: 'club' } }
    end

    before do
      allow(RibonCoreApi).to receive(:redis).and_return(MockRedis.new)
      create_list(:ticket, 10, user: account.user, status: :to_collect, category: :daily, source: :club)
      create_list(:ticket, 5, user: account.user, status: :to_collect, category: :monthly, source: :club)
    end

    it 'returns the quantity of tickets to_collect for that user' do
      request

      expect(response.body).to eq({ daily_tickets: 10, monthly_tickets: 5 }.to_json)
    end
  end
end
