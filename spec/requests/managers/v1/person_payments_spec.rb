require 'rails_helper'

RSpec.describe 'Managers::V1::PersonPayments', type: :request do
  describe 'GET /index' do
    subject(:request) do
      get '/managers/v1/person_payments', params: { params: query_params }
    end

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }
    let(:person_payments) { create_list(:person_payment, 20) }

    before do
      person_payments
      request
    end

    context 'when there are 20 person_payments' do
      let(:query_params) do
        '{"per_page":10,"page":1,"search_term":"", "status": ["refunded","paid","processing","failed"]}'
      end

      it 'returns a only 10 records per page' do
        expect(response_json.count).to eq(10)
      end

      it 'returns a list of person_payments' do
        expect_response_collection_to_have_keys(%w[amount_cents crypto_amount external_id id
                                                   offer page paid_date payment_method
                                                   payer payer_identification
                                                   service_fees status total_items total_pages platform
                                                   subscription_id])
      end

      it 'returns the total number of pages' do
        expect(response_json[0]['total_pages']).to eq(2)
      end

      it 'returns the total number of items' do
        expect(response_json[0]['total_items']).to eq(20)
      end
    end

    context 'when there is a search term' do
      let(:query_params) do
        "{\"per_page\":10,\"page\":1,\"search_term\":\"#{email_search}\",
        \"status\": [\"refunded\",\"paid\",\"processing\",\"failed\"]}"
      end
      let(:email_search) { person_payments.first.payer.email }

      it 'returns only records that match the search term' do
        expect(response_json.count).to eq(1)
      end
    end

    context 'when there is filter by status' do
      let(:query_params) do
        '{"per_page":10,"page":1,"search_term":"", "status": ["paid"]}'
      end
      let(:person_payments_count) { person_payments.select { |pp| pp.status == 'paid' }.count }

      it 'returns only records that match the status' do
        expect(response_json.count).to eq(person_payments_count)
      end
    end
  end
end
