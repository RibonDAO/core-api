require 'rails_helper'

RSpec.describe 'Api::V1::Tickets::Tickets', type: :request do
  describe 'get /tickets/available' do
    subject(:request) { get '/api/v1/tickets/available', headers: { Email: user.email } }

    let(:user) { create(:user) }

    context 'when user has tickets only from integration' do
      before do
        create_list(:ticket, 10, user:, status: :collected, source: :integration)
      end

      it 'returns the quantity of tickets available for that user' do
        request

        expect(response.body).to eq({ tickets: 10, integration_tickets: 10 }.to_json)
      end
    end

    context 'when user has tickets from integration and from club' do
      before do
        create_list(:ticket, 10, user:, status: :collected, source: :integration)
        create_list(:ticket, 10, user:, status: :collected, source: :club)
      end

      it 'returns the quantity of tickets available for that user' do
        request

        expect(response.body).to eq({ tickets: 20, integration_tickets: 10 }.to_json)
      end
    end

    context 'when user has no tickets' do
      it 'returns the quantity of tickets available for that user' do
        request

        expect(response.body).to eq({ tickets: 0, integration_tickets: 0 }.to_json)
      end
    end
  end

  describe 'get /tickets/to_collect' do
    include_context 'when making a user request' do
      subject(:request) do
        get '/api/v1/tickets/to_collect', headers: { Email: user.email }, params: { source: 'club' }
      end
    end

    let(:user) { create(:user) }

    before do
      create_list(:ticket, 10, user:, status: :to_collect, category: :daily, source: :club)
      create_list(:ticket, 5, user:, status: :to_collect, category: :monthly, source: :club)
    end

    it 'returns the quantity of tickets to_collect for that user' do
      request

      expect(response.body).to eq({ daily_tickets: 10, monthly_tickets: 5 }.to_json)
    end
  end
end
