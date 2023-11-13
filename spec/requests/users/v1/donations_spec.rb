require 'rails_helper'

RSpec.describe 'Users::V1::Donations', type: :request do
  describe 'POST /create' do
    include_context 'when making a user request' do
      let(:request) { post '/users/v1/donations', headers:, params: }
    end

    let(:integration) { create(:integration) }
    let(:non_profit) { create(:non_profit) }
    let(:user) { account.user }
    let(:platform) { 'web' }
    let(:params) do
      {
        integration_id: integration.id,
        non_profit_id: non_profit.id,
        platform:,
        utm_source: 'utm source',
        utm_medium: 'utm medium',
        utm_campaign: 'utm campaign'
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
        user:,
        platform:
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
      let(:donation) { build(:donation) }

      before do
        allow(Donations::Donate).to receive(:call)
          .and_return(command_double(klass: Donations::Donate,
                                     success: true, result: donation))
        allow(Tracking::AddUtm).to receive(:call)
      end

      it 'returns http status ok' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the donation' do
        request

        expect(response_json['donation'].keys)
          .to match_array %w[id created_at integration_id non_profit_id updated_at user_id value platform]
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtm).to have_received(:call)
      end
    end
  end

  describe 'POST /can_donate' do
    include_context 'when making a user request' do
      let(:request) do
        post '/users/v1/can_donate', headers:, params: { integration_id: integration.id }
      end
    end

    let(:integration) { create(:integration) }
    let(:user) { account.user }

    it 'returns the can_donate attribute' do
      request

      expect_response_to_have_keys %w[can_donate donate_app]
    end
  end
end
