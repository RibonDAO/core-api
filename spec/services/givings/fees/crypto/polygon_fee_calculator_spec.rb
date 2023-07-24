require 'rails_helper'

RSpec.describe Givings::Fees::Crypto::PolygonFeeCalculator, type: :service do
  subject(:service) { described_class.new(currency:) }

  describe '#calculate_fee' do
    include_context('when mocking a request') { let(:cassette_name) { 'polygon_gas_fee_request' } }

    let(:currency) { :brl }

    it 'calls the Api request with correct url' do
      allow(Request::ApiRequest).to receive(:get).and_call_original
      service.calculate_fee

      expect(Request::ApiRequest).to have_received(:get)
        .with(RibonCoreApi.config[:crypto_api][:polygon_gas_fee_url], { expires_in: 2.hours })
    end

    it 'gets the gas fee from polygon and returns in the currency' do
      result = service.calculate_fee
      expect(result.currency.to_s).to eq 'BRL'
      expect(result.to_f).to eq 2.12
    end
  end
end
