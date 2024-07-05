require 'rails_helper'

RSpec.describe 'Managers::V1::Coupons', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/managers/v1/coupons' }

    before do
      create_list(:coupon, 2)
    end

    it 'returns a list of coupons' do
      request
      expect_response_collection_to_have_keys(%w[id status available_quantity
                                                 expiration_date number_of_tickets
                                                 link coupon_message])
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/coupons/#{coupon.id}" }

    let(:coupon) { create(:coupon) }

    it 'returns a single coupon' do
      request

      expect_response_to_have_keys(%w[id status available_quantity
                                      expiration_date number_of_tickets
                                      link coupon_message])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/coupons', params: }

    context 'with the right params' do
      let(:params) do
        {
          available_quantity: 10,
          expiration_date: 1.day.from_now,
          number_of_tickets: 1,
          coupon_message_attributes: { reward_text: 'New reward' },
          status: 'active'
        }
      end

      it 'creates a new coupon' do
        expect { request }.to change(Coupon, :count).by(1)
      end

      it 'returns a single coupon' do
        request

        expect_response_to_have_keys(%w[id status available_quantity
                                        expiration_date number_of_tickets
                                        link coupon_message])
      end
    end

    context 'with the wrong params' do
      let(:params) do
        { available_quantity: nil, expiration_date: nil, number_of_tickets: nil, status: nil,
          coupon_message_attributes: { reward_text: nil } }
      end

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/managers/v1/coupons/#{coupon.id}", params: }

    let(:coupon) { create(:coupon) }

    context 'with the right params' do
      let(:params) do
        {
          available_quantity: 10,
          expiration_date: 1.day.from_now,
          number_of_tickets: 1,
          status: 'active',
          coupon_message_attributes: { reward_text: 'New reward' }
        }
      end

      it 'updates a coupon' do
        request
        expect(coupon.reload.available_quantity).to eq 10
        expect(coupon.reload.coupon_message.reward_text).to eq 'New reward'
      end

      it 'returns a single coupon' do
        request
        expect_response_to_have_keys(%w[id status available_quantity
                                        expiration_date number_of_tickets
                                        link coupon_message])
      end
    end

    context 'with the wrong params' do
      let(:params) do
        { available_quantity: nil, expiration_date: nil, number_of_tickets: nil, status: nil,
          coupon_message_attributes: { reward_text: nil } }
      end

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
