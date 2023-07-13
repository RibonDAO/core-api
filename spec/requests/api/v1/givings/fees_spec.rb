require 'rails_helper'

RSpec.describe 'Api::V1::Givings::Fees', type: :request do
  describe 'GET /card_fees' do
    subject(:request) { post '/api/v1/givings/card_fees', params: }

    let(:params) do
      { value: 50, currency: 'brl', gateway: :stripe }
    end
    let(:result) do
      {
        card_fee: Money.from_amount(2.39, :brl),
        crypto_fee: Money.from_amount(1.89, :brl),
        crypto_giving: Money.from_amount(8.73, :usd),
        giving_total: Money.from_amount(50.0, :brl),
        net_giving: Money.from_amount(45.72, :brl),
        service_fees: Money.from_amount(4.28, :brl)
      }
    end

    before do
      mock_command(klass: Givings::Card::CalculateCardGiving, result:)
      request
    end

    it 'calls the CalculateCardGiving command with correct params' do
      expect(Givings::Card::CalculateCardGiving)
        .to have_received(:call).with(value: params[:value].to_f,
                                      currency: params[:currency].downcase.to_sym,
                                      gateway: params[:gateway])
    end

    it 'returns all the giving fees information' do
      expect(response_json.keys).to match_array %w[card_fee crypto_fee crypto_giving giving_total
                                                   net_giving service_fees]
    end

    it 'returns the command result' do
      expect(response_json.to_json).to eq result.transform_values(&:format).to_json
    end
  end
end
