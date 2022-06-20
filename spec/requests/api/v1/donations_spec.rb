require 'rails_helper'

RSpec.describe 'Api::V1::Donations', type: :request do
  describe 'POST /create' do
    subject(:request) { post '/api/v1/donations', params: }

    let(:integration) { create(:integration) }
    let(:non_profit) { create(:non_profit) }
    let(:user) { create(:user) }
    let(:params) do
      {
        integration_id: integration.id,
        non_profit_id: non_profit.id,
        user_id: user.id
      }
    end

    before do
      allow(Donations::Donate).to receive(:call).and_return(command_double(klass: Donations::Donate))
      allow(Integration).to receive(:find).and_return(integration)
      allow(NonProfit).to receive(:find).and_return(non_profit)
      allow(User).to receive(:find_by).and_return(user)
    end

    it 'calls the donate command with right params' do
      request

      expect(Donations::Donate).to have_received(:call).with(
        integration:,
        non_profit:,
        user:
      )
    end

    context 'when the command fails' do
      before do
        allow(Donations::Donate).to receive(:call)
          .and_return(command_double(klass: Donations::Donate,
                                     success: false, errors: { message: 'error' }))
      end

      it 'returns http status unprocessable_entity' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end

      it 'returns an error message' do
        request

        expect(response_body.message).to eq 'error'
      end
    end

    context 'when the command is succeeded' do
      before do
        allow(Donations::Donate).to receive(:call)
          .and_return(command_double(klass: Donations::Donate,
                                     success: true, result: '0x000'))
      end

      it 'returns http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the transaction hash' do
        request

        expect(response_body.transaction_hash).to eq '0x000'
      end
    end
  end
end
