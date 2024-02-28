require 'rails_helper'

RSpec.describe 'Api::V1::Offers', type: :request do
  describe 'GET /v1/givings/offers' do
    subject(:request) { get url }

    let(:user) { create(:user) }
    let(:url) { '/api/v1/givings/offers/?currency=brl&subscription=true&category=direct_contribution' }
    let!(:active_offers) do
      create_list(:offer, 2, active: true, currency: :brl, subscription: true, category: 'direct_contribution')
    end

    before do
      create_list(:offer, 3, active: true, currency: :brl, subscription: true, category: 'club')
      create_list(:offer, 3, active: false, currency: :brl, subscription: true, category: 'direct_contribution')
    end

    it 'returns all active offers' do
      request

      expect(response_body.length).to eq 2
      response_body.each { |offer| expect(active_offers.pluck(:id)).to include(offer['id']) }
    end

    it 'returns all necessary keys' do
      request

      expect(response_json.first.keys)
        .to match_array %w[active created_at currency id position_order
                           price price_cents price_value subscription title updated_at external_id gateway category plan]
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/givings/offers/#{offer.id}" }

    let(:offer) { create(:offer) }

    it 'returns a single offer' do
      request

      expect_response_to_have_keys(%w[created_at id updated_at currency subscription price price_cents price_value
                                      active title position_order external_id gateway category])
    end
  end
end
