require 'rails_helper'

RSpec.describe 'Api::V1::UserGivingsController', type: :request do
  describe 'GET /v1/givings/user_givings' do
    subject(:request) { get url }

    let(:customer) { create(:customer) }
    let(:email) { customer.email }
    let(:currency) { :usd }
    let(:url) { "/api/v1/givings/user_givings?email=#{email}&currency=#{currency}" }
    let!(:paid_payment) do
      create_list(:person_payment, 2, status: :paid, payer: customer,
                                      offer: create(:offer, currency: :usd, price_cents: 1000))
    end

    include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_usd_brl' } }

    it 'returns all payed payments' do
      request

      expect(response_body.length).to eq 2
      response_body.each { |payment| expect(paid_payment.pluck(:id)).to include(payment['id']) }
    end

    it 'returns correct amount of user giving' do
      request

      expect(response_body.first['crypto_amount']).to eq 10.00
    end
  end
end
