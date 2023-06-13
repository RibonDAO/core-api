require 'rails_helper'

RSpec.describe 'Api::V1::Vouchers::Donations', type: :request do
  describe 'POST /create' do
    subject(:request) { post '/api/v1/vouchers/donations', params: }

    include_context('when mocking a request') { let(:cassette_name) { 'sendgrid_email_api' } }

    let(:integration) { create(:integration) }
    let(:non_profit) { create(:non_profit, :with_impact) }
    let(:user) { create(:user) }
    let(:external_id) { 'external_id' }
    let(:params) do
      {
        integration_id: integration.id,
        non_profit_id: non_profit.id,
        email: user.email,
        external_id:
      }
    end

    before do
      create(:chain)
      create(:ribon_config)
    end

    context 'when the donate command succeeds' do
      it 'returns http status created' do
        request

        expect(response).to have_http_status(:created)
      end

      it 'returns the voucher' do
        request
        expect(response_body.external_id).to eq external_id
        expect(response_body.donation).to be_present
      end
    end

    context 'when the request has a repeated external id' do
      before do
        create(:voucher, external_id:, integration_id: integration.id)
      end

      it 'returns http status unprocessable entity' do
        request

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a voucher' do
        expect { request }.not_to change(Voucher, :count)
      end

      it 'does not create a donation' do
        expect { request }.not_to change(Donation, :count)
      end
    end
  end
end
