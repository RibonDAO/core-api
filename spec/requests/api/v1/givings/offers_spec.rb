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
        .to match_array %w[active created_at currency id position_order
                           price price_cents price_value subscription title updated_at gateway]
    end
  end

  describe 'GET /v1/givings/offers_manager' do
    subject(:request) { get url }

    let(:user) { create(:user) }
    let(:url) { '/api/v1/givings/offers_manager' }
    let!(:offers) { create_list(:offer, 2) }

    it 'returns all offers' do
      request

      expect(response_body.length).to eq 2
      response_body.each { |offer| expect(offers.pluck(:id)).to include(offer['id']) }
    end

    it 'returns all necessary keys' do
      request

      expect(response_json.first.keys)
        .to match_array %w[active created_at currency id position_order external_id gateway
                           price price_cents price_value subscription title updated_at]
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/givings/offers/#{offer.id}" }

    let(:offer) { create(:offer) }

    it 'returns a single offer' do
      request

      expect_response_to_have_keys(%w[created_at id updated_at currency subscription price price_cents price_value
                                      active title position_order external_id gateway])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/givings/offers', params: }

    context 'with the right params' do
      let(:params) do
        { price_cents: '1', currency: 'brl', offer_gateway_attributes: {
          gateway: 'stripe', external_id: 'id_123'
        } }
      end
      let(:result) { create(:offer) }

      before do
        mock_command(klass: Offers::UpsertOffer, result:)
      end

      it 'calls the upsert command with right params' do
        request

        expect(Offers::UpsertOffer).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single offer' do
        request

        expect_response_to_have_keys(%w[created_at id updated_at currency subscription price price_cents
                                        price_value active title position_order external_id gateway])
      end
    end
  end

  describe 'PUT /update' do
    context 'with the right params' do
      subject(:request) { put "/api/v1/givings/offers/#{offer.id}", params: }

      let(:offer) { create(:offer) }
      let(:params) do
        { id: offer.id.to_s, currency: 'brl', price_cents: '1', offer_gateway_attributes: {
          id: offer.id.to_s,
          external_id: 'id_1234',
          gateway: 'stripe'
        } }
      end

      it 'calls the upsert command with right params' do
        allow(Offers::UpsertOffer).to receive(:call).and_return(command_double(klass: Offers::UpsertOffer,
                                                                               result: offer))
        request

        expect(Offers::UpsertOffer).to have_received(:call).with(strong_params(params))
      end

      it 'updates the offer' do
        request

        expect(offer.reload.external_id).to eq('id_1234')
      end
    end
  end
end
