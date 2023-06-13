require 'rails_helper'

RSpec.describe 'Api::V1::Site::Site', type: :request do
  describe 'GET /non_profits' do
    subject(:request) { get '/api/v1/site/non_profits' }

    before do
      create(:ribon_config, default_ticket_value: 100)
      create_list(:non_profit, 4, :with_impact)
    end

    it 'returns a list of non profits' do
      request

      expect_response_collection_to_have_keys(%w[description logo main_image])
    end

    it 'returns 3 last non profits' do
      request

      expect(response_json.count).to eq(3)
    end
  end

  describe 'GET /total_donations?language=pt-BR' do
    subject(:request) { get '/api/v1/site/total_donations?language=pt-BR' }

    let(:balance) { create(:balance, created_at: Time.zone.yesterday + 1.hour) }

    before do
      allow(Currency::Converters).to receive(:convert_to_brl).and_return(1)
    end

    it 'returns all funds for donation' do
      request

      expect(response_json.to_json).to eq({ total_donations: 'R$ 1' }.to_json)
    end
  end

  describe 'GET /total_donations' do
    subject(:request) { get '/api/v1/site/total_donations' }

    let(:balance) { create(:balance, created_at: Time.zone.yesterday + 1.hour) }
    let(:total_donations) do
      BalanceHistory
        .where('created_at > ?', Time.zone.yesterday)
        .where('created_at < ?', Time.zone.today).sum(:balance)&.round
    end

    it 'returns all funds for donation' do
      request

      expect(response_json.to_json).to eq({ total_donations: "#{total_donations} USDC" }.to_json)
    end
  end

  describe 'GET /total_impacted_lives' do
    subject(:request) { get '/api/v1/site/total_impacted_lives' }

    let(:total_impacted_lives) { { total_impacted_lives: '470.770' } }

    it 'returns a mocked data' do
      request

      expect(response_json.to_json).to eq(total_impacted_lives.to_json)
    end
  end
end
