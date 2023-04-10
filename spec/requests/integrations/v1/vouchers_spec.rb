require 'rails_helper'

RSpec.describe 'Integrations::V1::Vouchers', type: :request do
  describe 'GET /show' do
    include_context('when making an integration request') do
      let(:request) { get "/integrations/v1/vouchers/#{voucher.external_id}", headers: }
    end

    let!(:voucher) { create(:voucher, integration:) }

    it 'returns the voucher for the integration' do
      request

      expect(response_body.id).to eq voucher.id
    end

    it 'returns the correct fields' do
      request

      expect(response_json.keys).to match_array(%w[id created_at donation external_id
                                                   updated_at callback_url])
    end

    context 'when the voucher is not found' do
      include_context('when making an integration request') do
        let(:request) { get '/integrations/v1/vouchers/invalid_external_id', headers: }
      end

      it 'returns not found' do
        request

        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        request

        expect(response_body.error).to eq I18n.t('vouchers.invalid_voucher')
      end
    end
  end
end
