require 'rails_helper'

RSpec.describe 'Api::V1::Tags', type: :request do
  describe 'GET /index with 2 tags available' do
    subject(:request) { get '/api/v1/tags' }

    let!(:chain) { create(:chain) }
    let!(:token) { create(:token, chain:) }
    let!(:cause) { create(:cause) }
    let!(:pool) { create(:pool, cause:, token:) }
    let!(:pool2) { create(:pool, cause:) }
    let!(:pool_balance) { create(:pool_balance, balance: 1, pool:) }
    let!(:pool_balance2) { create(:pool_balance, balance: 1, pool: pool2) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:tag) { create(:tag) }
    let!(:tag2) { create(:tag) }
    let!(:non_profit_tags) { create(:non_profit_tag, non_profit:, tag:) }
    let!(:non_profit_tags2) { create(:non_profit_tag, non_profit:, tag: tag2) }

    before do
      create(:ribon_config, default_chain_id: chain.chain_id)
    end

    it 'returns a list of tags' do
      request

      expect_response_collection_to_have_keys(%w[created_at id name status updated_at non_profits])
    end

    it 'returns 2 tags' do
      request

      expect(response_json.count).to eq(2)
    end
  end
end
