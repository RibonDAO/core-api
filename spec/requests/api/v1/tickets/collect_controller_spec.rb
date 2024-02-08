require 'rails_helper'

RSpec.describe 'Api::V1::Tickets::Collect', type: :request do
  describe 'POST /can_collect_by_integration' do
    subject(:request) { post '/api/v1/tickets/can_collect_by_integration', params: }

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:params) do
        {
          integration_id: integration.id,
          email: user.email
        }
      end

      it 'returns true' do
        request

        expect(JSON.parse(response.body)['can_collect']).to be true
      end
    end

    context 'with no user' do
      let(:integration) { create(:integration) }
      let(:params) do
        {
          integration_id: integration.id
        }
      end

      it 'returns true' do
        request

        expect(JSON.parse(response.body)['can_collect']).to be true
      end
    end
  end

  describe 'POST /collect_by_integration' do
    subject(:request) { post '/api/v1/tickets/collect_by_integration', params: }

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:platform) { 'web' }
      let(:params) do
        {
          integration_id: integration.id,
          email: user.email,
          platform:,
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tickets::CanCollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectByIntegration))
        allow(Tickets::CollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByIntegration))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectByIntegration command with right params' do
        request

        expect(Tickets::CollectByIntegration).to have_received(:call).with(
          integration:,
          user:,
          platform:
        )
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtm).to have_received(:call)
      end

      it 'returns success' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the ticket' do
        request

        expect_response_to_have_keys(%w[ticket])
      end
    end

    context 'with wrong params' do
      let(:integration) { create(:integration) }
      let(:params) do
        {
          integration_id: integration.id,
          email: 1
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'POST /can_collect_by_external_ids' do
    subject(:request) { post '/api/v1/tickets/can_collect_by_external_ids', params: }

    let(:external_ids) { %w[1 2] }

    context 'with right params' do
      let(:params) do
        {
          external_ids:
        }
      end

      it 'returns true' do
        request
        expect(JSON.parse(response.body)['can_collect']).to be(true)
      end
    end

    context 'with external id already used' do
      let(:params) do
        {
          external_ids: ['1']
        }
      end

      it 'returns false' do
        create(:voucher, external_id: '1')
        request

        expect(JSON.parse(response.body)['can_collect']).to be(false)
      end
    end
  end

  describe 'POST /collect_by_external_ids' do
    subject(:request) { post '/api/v1/tickets/collect_by_external_ids', params: }

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:platform) { 'web' }
      let(:external_ids) { ['13'] }
      let(:params) do
        {
          integration_id: integration.id,
          email: user.email,
          platform:,
          external_ids:,
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tickets::CanCollectByExternalId).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectByExternalId))
        allow(Tickets::CollectByExternalIds).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByExternalIds))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectByExternalIds command with right params' do
        request

        expect(Tickets::CollectByExternalIds).to have_received(:call).with(
          integration:,
          user:,
          platform:,
          external_ids:
        )
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtm).to have_received(:call)
      end

      it 'returns success' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the ticket' do
        request

        expect_response_to_have_keys(%w[ticket])
      end
    end

    context 'with wrong params' do
      let(:integration) { create(:integration) }
      let(:params) do
        {
          integration_id: integration.id,
          email: 1,
          external_ids: ['13']
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
