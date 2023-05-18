require 'rails_helper'

RSpec.describe 'Api::V1::Chains', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/chains' }

    before do
      create_list(:chain, 2)
    end

    it 'returns a list of causes' do
      request

      expect_response_collection_to_have_keys(%w[id name ribon_contract_address donation_token_contract_address
                                                 chain_id rpc_url symbol_name currency_name block_explorer_url
                                                 default_donation_pool_address node_url])
    end

    it 'returns 2 chains' do
      request

      expect(response_json.count).to eq(2)
    end
  end
end
