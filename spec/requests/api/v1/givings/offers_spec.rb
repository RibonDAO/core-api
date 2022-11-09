require 'rails_helper'

RSpec.describe 'Api::V1::Offers', type: :request do
  describe 'GET /v1/givings/offers' do
    subject(:request) { get url }

    let(:user) { create(:user) }
    let(:url) { '/api/v1/givings/offers?currency=brl&subscription=true' }
    let!(:active_offers) { create_list(:offer, 2, active: true, currency: :brl, subscription: true) }

    before do
      create_list(:offer, 3, active: false, currency: :brl, subscription: true)
    end

    it 'returns all active offers' do
      request

      expect(response_body.length).to eq 2
      response_body.each { |offer| expect(active_offers.pluck(:id)).to include(offer['id']) }
    end

    it 'returns all necessary keys' do
      request

      expect(response_json.first.keys)
        .to match_array %w[active created_at currency id position_order external_id gateway
                           price price_cents price_value subscription title updated_at]
    end
  end
end
