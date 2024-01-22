require 'rails_helper'

RSpec.describe 'Users::V1::Tickets::Tickets', type: :request do
  describe 'get /tickets/available' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/tickets/available', headers: }
    end

    before do
      create_list(:ticket, 10, user: account.user)
    end

    it 'returns the quantity of tickets available for that user' do
      request

      expect(response.body).to eq({ tickets: 10 }.to_json)
    end
  end
end
