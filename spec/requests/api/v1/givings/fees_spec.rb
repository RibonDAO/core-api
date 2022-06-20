require 'rails_helper'

RSpec.describe 'Api::V1::Givings::Fees', type: :request do
  describe 'GET /card_fees' do
    subject(:request) { post '/api/v1/givings/card_fees', params: }

    let(:params) do
      { value: 50, currency: 'brl' }
    end
    let(:result) do
      {
        card_fee: 'R$2.39', crypto_fee: 'R$1.89',
        crypto_giving: '$8.73', giving_total: 'R$50.00',
        net_giving: 'R$45.72', service_fees: 'R$4.28'
      }
    end

    before do
      mock_command(klass: Givings::Card::CalculateStripeGiving, result:)
      request
    end

    it 'calls the CalculateStripeGiving command with correct params' do
      expect(Givings::Card::CalculateStripeGiving)
        .to have_received(:call)
        .with(value: params[:value].to_f, currency: params[:currency].downcase.to_sym)
    end

    it 'returns all the giving fees information' do
      expect(response_json.keys).to match_array %w[card_fee crypto_fee crypto_giving giving_total
                                                   net_giving service_fees]
    end

    it 'returns the command result' do
      expect(response_json.to_json).to eq result.to_json
    end
  end
end
