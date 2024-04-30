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
                                                 expiration_date number_of_tickets reward_text
                                                 link])
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/coupons/#{coupon.id}" }

    let(:coupon) { create(:coupon) }

    it 'returns a single coupon' do
      request

      expect_response_to_have_keys(%w[id status available_quantity
                                      expiration_date number_of_tickets reward_text
                                      link])
    end
  end
end
