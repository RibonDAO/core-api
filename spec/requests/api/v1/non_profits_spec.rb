require 'rails_helper'

RSpec.describe 'Api::V1::NonProfits', type: :request do
  describe 'GET /index' do
    before do
      create(:chain)
      create(:ribon_config)
    end

    describe 'GET /index with 2 non profits available' do
      subject(:request) { get '/api/v1/non_profits' }

      before do
        create_list(:non_profit, 2)
      end

      it 'returns a list of non profits' do
        request

        expect_response_collection_to_have_keys(%w[created_at id impact_description name updated_at
                                                   wallet_address background_image logo main_image
                                                   impact_by_ticket stories cause status non_profit_impacts])
      end

      it 'returns 2 non profits' do
        request

        expect(response_json.count).to eq(2)
      end
    end

    describe 'GET /index with 1 non profit available because of status' do
      subject(:request) { get '/api/v1/non_profits' }

      before do
        create(:non_profit)
        create_list(:non_profit, 2, status: :inactive)
      end

      it 'returns 1 non profits' do
        request

        expect(response_json.count).to eq(1)
      end
    end

    describe 'GET /index with 1 non profit available because of pool balance' do
      subject(:request) { get '/api/v1/non_profits' }

      let!(:cause) { create(:cause) }
      let!(:pool) { create(:pool, cause:) }

      before do
        create(:pool_balance, pool:, balance: 0)
        create(:non_profit)
        create_list(:non_profit, 2, cause:, status: :active)
      end

      it 'returns 1 non profit' do
        request

        expect(response_json.count).to eq(1)
      end
    end
  end

  describe 'GET /stories' do
    subject(:request) { get "/api/v1/non_profits/#{non_profit.id}/stories" }

    let(:non_profit) { create(:non_profit) }

    before do
      create_list(:story, 2, non_profit:)
    end

    it 'returns a list of stories' do
      request

      expect_response_collection_to_have_keys(%w[active description id image position title])
    end

    it 'returns 2 stories' do
      request

      expect(response_json.count).to eq(2)
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/non_profits', params: }

    let(:params) do
      {
        name: 'Ribon',
        status: :inactive
      }
    end

    let!(:result) { create(:non_profit) }

    before do
      mock_command(klass: NonProfits::CreateNonProfit, result:)
      request
    end

    it 'returns a single non_profit' do
      expect_response_to_have_keys(%w[background_image cause created_at id impact_by_ticket impact_description logo
                                      main_image name status stories updated_at wallet_address non_profit_impacts])
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/non_profits/#{non_profit.id}" }

    let(:non_profit) { create(:non_profit) }

    it 'returns a single non_profit' do
      request

      expect_response_to_have_keys(%w[background_image cause created_at id impact_by_ticket impact_description logo
                                      main_image name status stories updated_at wallet_address non_profit_impacts])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/api/v1/non_profits/#{non_profit.id}", params: }

    let(:non_profit) { create(:non_profit) }
    let(:params) { { name: 'New Name' } }

    it 'updates the non_profit' do
      request

      expect(non_profit.reload.name).to eq('New Name')
    end
  end
end
